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
  , restrictedSources
  ) where

import           Control.Concurrent.MVar
import           Control.Concurrent             (threadDelay)
import           Control.Concurrent.Async       (race)
import           Control.Exception              (SomeException, finally, try, mask, mask_)
import           Control.Monad                  (forever, void, when)
import           Control.Monad.IO.Class         (liftIO)
import           Data.Aeson                     (Value, eitherDecodeStrict, encode,
                                                 object, (.=))
import           Data.IORef
import qualified Data.ByteString.Char8          as BC
import qualified Data.Map                       as M
import           Data.Maybe                     (fromMaybe)
import qualified Data.Set                       as S
import           Data.Text                      (Text)
import qualified Data.Text                      as T
import           Network.HTTP.Types             (hContentType, status200,
                                                 status404)
import           Network.Wai                    (Application, responseFile,
                                                 responseLBS, requestHeaders, mapResponseHeaders)
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
import           Refl.Server.Identity

data ServerEnv = ServerEnv
  { seConfig   :: Config
  , seEnv      :: Env
  , seGame     :: LoadedGame
  , seManifest :: Manifest
  , seSources  :: SourceIndex
  , seProgress :: ProgressStore
  , seSlots :: MVar Int
  }

newServerEnv :: Config -> Env -> LoadedGame -> ProgressStore -> IO ServerEnv
newServerEnv cfg env game store = do
 slots <- newMVar 0
 pure ServerEnv
  { seConfig = cfg
  , seEnv = env
  , seGame = game
  , seManifest = buildManifest languageInfos game
  , seSources = sourceIndex game
  , seProgress = store
  , seSlots = slots
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

-- | Both content CI and live sessions enforce the same earned vocabulary.
restrictedSources :: LoadedGame -> LevelSources -> LevelSources
restrictedSources game src = src { lsForbidsNames = S.toList forbids }
 where
  allNames = S.fromList
    [ n | w <- lgWorlds game, l <- lwLevels w, sp <- usLemmas (lmUnlocks (llMeta l)), n <- M.elems (lsNames sp) ]
  earned = M.findWithDefault S.empty (lsWorld src, lsLevel src) (unlockedLemmas game)
  forbids = S.fromList (lsForbidsNames src) `S.union` (allNames `S.difference` earned)

-- ---------------------------------------------------------------------------
-- HTTP
-- ---------------------------------------------------------------------------

type Api =
       "api" :> "health" :> Get '[JSON] Value
  :<|> "api" :> "progress" :> Get '[JSON] Progress
  :<|> "manifest.json" :> Get '[JSON] Manifest
  :<|> Raw

app :: ServerEnv -> Application
app se req respond = do
  let existing = identity (requestHeaders req)
  player <- maybe newIdentity pure existing
  let scoped = se { seProgress = playerStore (seProgress se) (BC.unpack player) }
      cookie = [("Set-Cookie", identityCookie player) | existing == Nothing]
      options = WS.defaultConnectionOptions
        { WS.connectionFramePayloadSizeLimit = WS.SizeLimit (fromIntegral (cfgMessageBytes (seConfig se)))
        , WS.connectionMessageDataSizeLimit = WS.SizeLimit (fromIntegral (cfgMessageBytes (seConfig se))) }
  cors (websocketsOr options (wsApp scoped) (serve (Proxy :: Proxy Api) (server scoped))) req
    (respond . mapResponseHeaders (cookie ++))
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
  | not (validOrigin expected headers) = WS.rejectRequest pending "origin rejected"
  | identity headers == Nothing = WS.rejectRequest pending "open the site first"
  | WS.requestPath (WS.pendingRequest pending) == "/ws" = do
      mask $ \restore -> do
        admitted <- modifyMVar (seSlots se) $ \n ->
          if n < cfgMaxSessions cfg then pure (n + 1, True) else pure (n, False)
        if not admitted then WS.rejectRequest pending "session capacity reached" else
          restore (do
            conn <- WS.acceptRequest pending
            sessionVar <- newMVar Nothing
            let closeSession = do
                  ms <- swapMVar sessionVar Nothing
                  mapM_ (\s -> void (try (psClose (ssProver s)) :: IO (Either SomeException ()))) ms
            WS.withPingThread conn 30 (pure ()) $
              (loop conn sessionVar `finally` closeSession))
          `finally` modifyMVar_ (seSlots se) (pure . subtract 1)
  | otherwise = WS.rejectRequest pending "not found"
 where
  cfg = seConfig se
  headers = WS.requestHeaders (WS.pendingRequest pending)
  expected = BC.pack (fromMaybe ("http://" ++ cfgHost cfg ++ ":" ++ show (cfgPort cfg)) (cfgOrigin cfg))
  bounded secs action = race (threadDelay (secs * 1000000)) action >>= \case
    Left () -> fail "session time limit exceeded"
    Right value -> pure value
  loop conn sessionVar = void $ try @SomeException $ forever $ do
    raw <- bounded (cfgIdleSeconds cfg) (WS.receiveData conn)
    case eitherDecodeStrict raw of
      Left e -> send conn (ServerError ("Unreadable message: " <> T.pack e))
      Right msg -> do
        outcome <- try @SomeException (bounded (cfgCommandSeconds cfg) (handle conn sessionVar msg))
        case outcome of
          Right () -> pure ()
          Left e -> do
            logMsg (seEnv se) ("Session failed: " <> T.pack (show e))
            old <- swapMVar sessionVar Nothing
            mapM_ (\s -> void (try @SomeException (psClose (ssProver s)))) old
            send conn (SessionUnavailable ("Prover failed: " <> T.pack (show e) <> ". Retry the session."))
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
        (Just l, Just src0) -> mask_ $ do
          let key = levelKey world level
              src = restrictedSources (seGame se) src0
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
