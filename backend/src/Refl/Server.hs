-- | The WAI application: a small JSON API, the websocket that owns one prover
-- session per connection, and the static SPA with an index.html fallback.
--
-- Shape copied from xpsoasis/backend/src/Server.hs (websocketsOr in front of
-- servant, Raw fallback) and Handler/WebSocket.hs.
module Refl.Server
  ( ServerEnv (..)
  , newServerEnv
  , app
  , unlockedLemmas
  ) where

import           Control.Concurrent.MVar
import           Control.Exception              (SomeException, finally, try)
import           Control.Monad                  (forever, void, when)
import           Control.Monad.IO.Class         (liftIO)
import           Data.Aeson                     (Value, decodeStrict, encode,
                                                 object, (.=))
import qualified Data.ByteString.Lazy           as BL
import           Data.IORef
import qualified Data.Map                       as M
import           Data.Maybe                     (fromMaybe)
import qualified Data.Set                       as S
import           Data.Text                      (Text)
import qualified Data.Text                      as T
import qualified Data.Text.Encoding             as TE
import           Network.HTTP.Types             (hContentType, status200,
                                                 status404)
import           Network.Wai                    (Application, responseFile,
                                                 responseLBS)
import           Network.Wai.Application.Static (defaultWebAppSettings,
                                                 staticApp)
import           Network.Wai.Handler.WebSockets (websocketsOr)
import           Network.Wai.Middleware.AddHeaders (addHeaders)
import qualified Network.WebSockets             as WS
import           Servant                        hiding (ServerError)
import           System.FilePath                ((</>))
import           WaiAppStatic.Types             (MaxAge (NoMaxAge),
                                                 StaticSettings (..))

import           Refl.Config
import           Refl.Content
import           Refl.Language
import           Refl.Language.Registry
import           Refl.Protocol
import           Refl.Server.Progress

data ServerEnv = ServerEnv
  { seConfig   :: Config
  , seEnv      :: Env
  , seGame     :: LoadedGame
  , seManifest :: Manifest
  , seSources  :: SourceIndex
  , seUnlocked :: M.Map (WorldId, LevelId) (S.Set Text)
    -- ^ lemma names (all languages' spellings) available at each level
  , seAllLemmas :: S.Set Text
  , seProgress :: ProgressStore
  }

newServerEnv :: Config -> Env -> LoadedGame -> ProgressStore -> ServerEnv
newServerEnv cfg env game store = ServerEnv
  { seConfig = cfg
  , seEnv = env
  , seGame = game
  , seManifest = buildManifest languageInfos game
  , seSources = sourceIndex game
  , seUnlocked = unlockedLemmas game
  , seAllLemmas = S.fromList
      [ n | w <- lgWorlds game, l <- lwLevels w, sp <- usLemmas (lmUnlocks (llMeta l)), n <- M.elems (lsNames sp) ]
  , seProgress = store
  }

-- | For each level, the lemma spellings unlocked by this level and earlier
-- levels of the same world (a level may use the lemma it defines: that is
-- induction) and by every level of the worlds it transitively depends on.
unlockedLemmas :: LoadedGame -> M.Map (WorldId, LevelId) (S.Set Text)
unlockedLemmas game = M.fromList
  [ ((wid w, LevelId (lmId (llMeta l))), S.unions (depLemmas w : earlier w l))
  | w <- lgWorlds game, l <- lwLevels w ]
 where
  wid = WorldId . wmId . lwMeta
  byId = M.fromList [ (wmId (lwMeta w), w) | w <- lgWorlds game ]
  lemmasOf l = S.fromList [ n | sp <- usLemmas (lmUnlocks (llMeta l)), n <- M.elems (lsNames sp) ]
  worldLemmas w = S.unions (map lemmasOf (lwLevels w))
  transitive seen i
    | i `S.member` seen = seen
    | otherwise = case M.lookup i byId of
        Nothing -> seen
        Just w -> foldl transitive (S.insert i seen) (wmDependencies (lwMeta w))
  depLemmas w = S.unions
    [ worldLemmas d | i <- S.toList (foldl transitive S.empty (wmDependencies (lwMeta w))), Just d <- [M.lookup i byId] ]
  earlier w l = [ lemmasOf l' | l' <- lwLevels w, lmIndex (llMeta l') <= lmIndex (llMeta l) ]

-- ---------------------------------------------------------------------------
-- HTTP
-- ---------------------------------------------------------------------------

type Api =
       "api" :> "health" :> Get '[JSON] Value
  :<|> "api" :> "progress" :> Get '[JSON] Progress
  :<|> "manifest.json" :> Get '[JSON] Manifest
  :<|> Raw

app :: ServerEnv -> Application
app se = cors (websocketsOr WS.defaultConnectionOptions (wsApp se) (serve (Proxy :: Proxy Api) (server se)))
 where
  cors | cfgDev (seConfig se) = addHeaders [("Access-Control-Allow-Origin", "*")]
       | otherwise = id

server :: ServerEnv -> Server Api
server se =
       pure (object ["ok" .= True, "levels" .= M.size (seSources se)])
  :<|> liftIO (getProgress (seProgress se))
  :<|> pure (seManifest se)
  :<|> Tagged (spaApp se)

-- | Static file if it exists, else index.html (client-side routing).
spaApp :: ServerEnv -> Application
spaApp se = case cfgWww (seConfig se) of
  Nothing -> \_ send -> send (responseLBS status404 [(hContentType, "text/plain")] "refl-server: started without --www; only /api, /manifest.json and /ws are served.")
  Just dir -> staticApp (defaultWebAppSettings dir)
    { ss404Handler = Just (serveIndex dir)
    , ssMaxAge = NoMaxAge
    }
 where
  serveIndex dir _req send = send $
    responseFile status200 [(hContentType, "text/html; charset=utf-8")] (dir </> "index.html") Nothing

-- ---------------------------------------------------------------------------
-- WebSocket: one prover session per connection
-- ---------------------------------------------------------------------------

data Session = Session
  { ssLang    :: Language
  , ssSources :: LevelSources
  , ssProver  :: ProverSession
  , ssText    :: IORef Text
  , ssKey     :: Text
  }

wsApp :: ServerEnv -> WS.ServerApp
wsApp se pending
  | WS.requestPath (WS.pendingRequest pending) == "/ws" = do
      conn <- WS.acceptRequest pending
      sessionVar <- newMVar Nothing
      let closeSession = do
            ms <- swapMVar sessionVar Nothing
            mapM_ (\s -> void (try (psClose (ssProver s)) :: IO (Either SomeException ()))) ms
      WS.withPingThread conn 30 (pure ()) $
        (loop conn sessionVar `finally` closeSession)
  | otherwise = WS.rejectRequest pending "not found"
 where
  loop conn sessionVar = void $ try @SomeException $ forever $ do
    raw <- WS.receiveData conn
    case decodeStrict raw of
      Nothing -> send conn (ServerError ("unreadable message: " <> TE.decodeUtf8 (BL.toStrict (BL.take 200 (BL.fromStrict raw)))))
      Just msg -> handle conn sessionVar msg
  send conn m = WS.sendTextData conn (encode m)

  handle conn sessionVar = \case
    Ping -> send conn Pong
    GetProgress -> getProgress (seProgress se) >>= send conn . ProgressState
    OpenSession lang world level -> do
      -- close the previous one first
      old <- swapMVar sessionVar Nothing
      mapM_ (\s -> void (try (psClose (ssProver s)) :: IO (Either SomeException ()))) old
      case (lookupLanguage lang, M.lookup (world, level, lang) (seSources se)) of
        (Nothing, _) -> send conn (SessionUnavailable ("unknown language " <> unLangId lang))
        (Just l, _) | not (liAvailable (langInfo l)) ->
          send conn (SessionUnavailable (liName (langInfo l) <> " is not available yet."))
        (_, Nothing) -> send conn (SessionUnavailable "This level has no source for that language.")
        (Just l, Just src0) -> do
          let key = levelKey world level
              unlocked = fromMaybe S.empty (M.lookup (world, level) (seUnlocked se))
              forbids = S.toList (S.union (S.fromList (lsForbidsNames src0)) (seAllLemmas se `S.difference` unlocked))
              src = src0 { lsForbidsNames = forbids }
          r <- langStart l (seEnv se) src
          case r of
            Left e -> send conn (SessionUnavailable e)
            Right prover -> do
              draft <- draftFor (seProgress se) key lang
              let initial = fromMaybe (lsTemplate src) draft
              ref <- newIORef initial
              void (swapMVar sessionVar (Just (Session l src prover ref key)))
              send conn (SessionOpened (langInfo l) (langCommands l) initial)
    Check txt -> withSession sessionVar conn $ \s -> do
      writeIORef (ssText s) txt
      res <- psCheck (ssProver s) txt
      record s res
      send conn (Checked res)
    HoleCmd target op -> withSession sessionVar conn $ \s -> do
      txt <- readIORef (ssText s)
      out <- psHole (ssProver s) txt target op
      case out of
        OutGoal g -> send conn (GoalShown g)
        OutInfo t b -> send conn (Info t b)
        OutError e -> send conn (ServerError e)
        OutText new -> do
          writeIORef (ssText s) new
          res <- psCheck (ssProver s) new
          record s res
          send conn (TextReplaced new (Just res))
    SaveDraft txt -> withSession sessionVar conn $ \s -> do
      writeIORef (ssText s) txt
      saveDraft (seProgress se) (ssKey s) (liId (langInfo (ssLang s))) txt

  withSession sessionVar conn k = do
    ms <- readMVar sessionVar
    case ms of
      Nothing -> send conn (ServerError "No level is open in this session.")
      Just s -> k s

  record s res = do
    let lang = liId (langInfo (ssLang s))
    txt <- readIORef (ssText s)
    saveDraft (seProgress se) (ssKey s) lang txt
    when (crVerdict res == Solved) $
      void (markSolved (seProgress se) lang (ssKey s))
