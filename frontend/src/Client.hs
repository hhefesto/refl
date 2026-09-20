-- | Talking to the backend: the manifest and progress over XHR, one
-- websocket per open level.
module Client
  ( backendBase
  , fetchManifest
  , fetchProgress
  , fetchDonations
  , postHit
  , fetchStats
  , fetchWorld
  , Conn (..)
  , connect
  ) where

import           Control.Monad.IO.Class (liftIO)
import           Control.Lens                ((&), (.~))
import           Data.Aeson                  (eitherDecodeStrict, encode)
import qualified Data.ByteString.Lazy        as BL
import qualified Data.Map                    as M
import           Data.Text                   (Text)
import qualified Data.Text                   as T
import qualified Data.Text.Encoding          as TE
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

-- | The donation addresses. A static file, not an endpoint: the same
-- @donations.json@ is what the website derivation reads to make the QR codes.
fetchDonations :: MonadWidget t m => Event t () -> m (Event t (Maybe Donations))
fetchDonations e = do
  base <- backendBase
  getAndDecode ((base <> "/donations.json") <$ e)

-- | The dashboard's aggregate. Under @\/dashboard\/@ rather than @\/api@ so
-- the browser resends the basic credentials it was already asked for.
fetchStats :: MonadWidget t m => Event t (Int, Int) -> m (Event t (Int, Either Text Summary))
fetchStats e = do
  base <- backendBase
  performEventAsync $ ffor e $ \(requestId, days) done -> do
    let req = XhrRequest "GET" (base <> "/dashboard/data.json?days=" <> T.pack (show days)) (def :: XhrRequestConfig ())
        decode (Left _) = Left "Could not reach the dashboard."
        decode (Right r)
          | _xhrResponse_status r /= 200 = Left ("Dashboard request failed (HTTP " <> T.pack (show (_xhrResponse_status r)) <> ").")
          | otherwise = maybe (Left "Invalid dashboard response.")
              (either (const (Left "Invalid dashboard response.")) Right . eitherDecodeStrict . TE.encodeUtf8) (_xhrResponse_responseText r)
    _ <- newXMLHttpRequestWithError req (liftIO . done . (requestId,) . decode)
    pure ()

-- | Country outlines, fetched only when the dashboard mounts: 130 kB of
-- geometry has no business in the bundle every visitor downloads.
fetchWorld :: MonadWidget t m => Event t () -> m (Event t (Maybe (M.Map Text Text)))
fetchWorld e = do
  base <- backendBase
  getAndDecode ((base <> "/world-countries.json") <$ e)

-- | Tell the server which page was opened. Hash routes never reach it, so
-- this is the only way it learns anything past the first document. Errors
-- are swallowed on purpose: a counter must never disturb the game.
postHit :: MonadWidget t m => Event t Hit -> m ()
postHit e = do
  base <- backendBase
  _ <- performRequestAsyncWithError (ffor e (postJson (base <> "/api/hit")))
  pure ()

data Conn t = Conn
  { connRecv  :: Event t ServerMsg
  , connOpen  :: Event t ()
  , connClose :: Event t ()
  , connError :: Event t Text
  }

-- | Open the websocket; messages are sent as JSON text frames.
connect :: MonadWidget t m => Event t [ClientMsg] -> Event t () -> Event t () -> m (Conn t)
connect sendE retryE leaveE = do
  base <- backendBase
  -- reflex-dom queues sends on a helper thread but closes synchronously, so a
  -- send and a close in one frame lose the send: close a little after leaving
  -- (the page itself is switched later still, see App).
  closeE <- delay 0.05 leaveE
  host <- getLocationHost
  proto <- getLocationProtocol
  let url | T.null base = (if proto == "https:" then "wss://" else "ws://") <> host <> "/ws"
          | otherwise = T.replace "http://" "ws://" (T.replace "https://" "wss://" base) <> "/ws"
  let socket = textWebSocket url $ def
        & webSocketConfig_send .~ fmap (map (TE.decodeUtf8 . BL.toStrict . encode)) sendE
        & webSocketConfig_close .~ ((1000, "Leaving level") <$ leftmost [closeE, retryE])
        & webSocketConfig_reconnect .~ False
  sockets <- widgetHold socket (socket <$ retryE)
  let received = switchDyn (_webSocket_recv <$> sockets)
      decoded = eitherDecodeStrict . TE.encodeUtf8 <$> received
  pure Conn
    { connRecv = fmapMaybe (either (const Nothing) Just) decoded
    , connOpen = switchDyn (_webSocket_open <$> sockets)
    , connClose = () <$ switchDyn (_webSocket_close <$> sockets)
    , connError = leftmost
        [ fmapMaybe (either (Just . ("Invalid server response: " <>) . T.pack) (const Nothing)) decoded
        , "Connection failed. Retry when the server is available." <$ switchDyn (_webSocket_error <$> sockets)
        ]
    }
