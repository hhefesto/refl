-- | Talking to the backend: the manifest and progress over XHR, one
-- websocket per open level.
module Client
  ( backendBase
  , fetchManifest
  , fetchProgress
  , Conn (..)
  , connect
  ) where

import           Control.Lens                ((&), (.~))
import           Data.Aeson                  (decodeStrict, encode)
import qualified Data.ByteString.Lazy        as BL
import           Data.Text                   (Text)
import qualified Data.Text                   as T
import           Language.Javascript.JSaddle (MonadJSM, fromJSVal, jsg, liftJSM, (!))
import           Reflex.Dom.Core

import           Refl.Protocol

-- | @window.reflBackend@ (set in index.html for the dev runner) or "" (same origin).
backendBase :: MonadJSM m => m Text
backendBase = liftJSM $ do
  v <- jsg ("window" :: Text) ! ("reflBackend" :: Text)
  mt <- fromJSVal v
  pure (maybe "" id mt)

fetchManifest :: MonadWidget t m => Event t () -> m (Event t (Maybe Manifest))
fetchManifest e = do
  base <- backendBase
  getAndDecode ((base <> "/manifest.json") <$ e)

fetchProgress :: MonadWidget t m => Event t () -> m (Event t (Maybe Progress))
fetchProgress e = do
  base <- backendBase
  getAndDecode ((base <> "/api/progress") <$ e)

data Conn t = Conn
  { connRecv  :: Event t ServerMsg
  , connOpen  :: Event t ()
  , connClose :: Event t ()
  }

-- | Open the websocket; messages are sent as JSON text frames.
connect :: MonadWidget t m => Event t [ClientMsg] -> m (Conn t)
connect sendE = do
  base <- backendBase
  host <- getLocationHost
  proto <- getLocationProtocol
  let url | T.null base = (if proto == "https:" then "wss://" else "ws://") <> host <> "/ws"
          | otherwise = T.replace "http://" "ws://" (T.replace "https://" "wss://" base) <> "/ws"
  ws <- webSocket url $ def
    & webSocketConfig_send .~ fmap (map (BL.toStrict . encode)) sendE
    & webSocketConfig_reconnect .~ False
  pure Conn
    { connRecv = fmapMaybe decodeStrict (_webSocket_recv ws)
    , connOpen = _webSocket_open ws
    , connClose = () <$ _webSocket_close ws
    }
