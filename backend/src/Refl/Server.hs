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
import           Control.Monad                  (forever, unless, void, when)
import           Control.Monad.IO.Class         (liftIO)
import           Data.Aeson                     (Value, eitherDecodeStrict, encode,
                                                 object, (.=))
import           Data.IORef
import qualified Data.ByteString                as BS
import qualified Data.ByteString.Char8          as BC
import qualified Data.Map                       as M
import           Data.Maybe                     (fromMaybe)
import qualified Data.Set                       as S
import           Data.Text                      (Text)
import qualified Data.Text                      as T
import           Data.Time                      (UTCTime, getCurrentTime, diffUTCTime)
import           Network.HTTP.Types             (hContentLength, hContentType, hReferer,
                                                 hUserAgent, status200, status302,
                                                 status404, status413)
import           Network.Wai                    (Request, pathInfo,
                                                 responseFile, responseHeaders,
                                                 responseLBS, requestHeaders, mapResponseHeaders)
import           Network.Wai.Application.Static (defaultWebAppSettings,
                                                 staticApp)
import           Network.Wai.Handler.WebSockets (websocketsOr)
import           Network.Wai.Middleware.AddHeaders (addHeaders)
import           Refl.Server.Access
import qualified Network.WebSockets             as WS
-- Servant.Summary is its Haddock-description combinator, which we do not
-- use and which would shadow the dashboard payload.
import           Servant                        hiding (ServerError, Summary)
import           System.FilePath                ((</>))
import           WaiAppStatic.Types             (MaxAge (NoMaxAge),
                                                 StaticSettings (..))

import           Refl.Config
import           Refl.Content
import           Refl.Language
import           Refl.Language.Registry
import           Refl.Protocol
import           Refl.Server.Analytics
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
  , seAnalytics :: Analytics
  , seDashPassword :: Maybe BS.ByteString
  -- Per request, filled in by 'app' next to seProgress, so the websocket
  -- handler can attribute what happens in a session to the same visitor.
  , seVisitor :: Text
  , seNewVisitor :: Bool
  , seAgent :: Text
  , seBrowser :: Text
  -- A global budget for /api/hit, so a script cannot fill the disk with
  -- events: refilled by the clock, never per visitor (that would be a map
  -- an attacker gets to grow).
  , seHitBudget :: IORef (UTCTime, Int)
  }

newServerEnv :: Config -> Env -> LoadedGame -> ProgressStore -> Analytics -> Maybe BS.ByteString -> IO ServerEnv
newServerEnv cfg env game store analytics dashPassword = do
 slots <- newMVar 0
 now <- getCurrentTime
 budget <- newIORef (now, hitBurst)
 pure ServerEnv
  { seConfig = cfg
  , seEnv = env
  , seGame = game
  , seManifest = buildManifest languageInfos game
  , seSources = sourceIndex game
  , seProgress = store
  , seSlots = slots
  , seAnalytics = analytics
  , seDashPassword = dashPassword
  , seVisitor = ""
  , seNewVisitor = False
  , seAgent = "unknown"
  , seBrowser = ""
  , seHitBudget = budget
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
  -- The SPA's own beacon: hash routes never reach the server, so nothing
  -- else can say which page or level a visitor actually looked at.
  :<|> "api" :> "hit" :> Header "Origin" Text :> ReqBody '[JSON] Hit :> Post '[JSON] Value
  -- Deliberately under /dashboard/ rather than /api: HTTP basic credentials
  -- are cached per directory, so the page and its data must share a prefix
  -- or the browser will not resend them and the fetch just 401s.
  :<|> "dashboard" :> "data.json" :> QueryParam "days" Int :> Get '[JSON] Summary
  :<|> "manifest.json" :> Get '[JSON] Manifest
  :<|> Raw

-- | How many /api/hit events may be recorded per second, and the burst.
hitRate, hitBurst :: Int
hitRate = 20
hitBurst = 200

app :: ServerEnv -> Application
app se = dashboardAuth (seDashPassword se) (core se)

-- | The SPA fallback answers /any/ unknown path with HTML, so @\/favicon.ico@
-- arrives looking exactly like a page and every visit would count twice.
-- Two independent filters, because neither covers the other's gap: browsers
-- label sub-resource fetches with @Sec-Fetch-Dest@, and a path ending in a
-- known asset extension was never a page. A probe for @\/wp-login.php@ is
-- deliberately still recorded — that is a crawler and worth seeing.
isPage :: Request -> Bool
isPage req = destOk && extOk
 where
  destOk = case lookup "Sec-Fetch-Dest" (requestHeaders req) of
    Just d -> d == "document"
    Nothing -> True
  extOk = case reverse (pathInfo req) of
    seg : _ -> not (any (`T.isSuffixOf` T.toLower seg) assetExtensions)
    [] -> True

assetExtensions :: [Text]
assetExtensions =
  [ ".ico", ".png", ".jpg", ".jpeg", ".svg", ".gif", ".webp", ".avif"
  , ".css", ".js", ".mjs", ".map", ".json", ".txt", ".xml", ".webmanifest"
  , ".woff", ".woff2", ".ttf", ".otf", ".eot" ]

core :: ServerEnv -> Application
core se req respond
  -- the credentials are cached against the directory, so land on one
  | pathInfo req == ["dashboard"] =
      respond (responseLBS status302 [("Location", "/dashboard/")] "")
  -- /api/hit carries two short strings; anything else is not the client
  | pathInfo req == ["api", "hit"] && not (smallBody req) =
      respond (responseLBS status413 [(hContentType, "text/plain")] "too large")
  | otherwise = do
      let policy = cookiePolicy (cfgOriginString (seConfig se))
          (agent, browser) = classifyAgent (fromMaybe "" (lookup hUserAgent (requestHeaders req)))
          existing = identity policy (requestHeaders req)
      player <- maybe newIdentity pure existing
      let scoped = se { seProgress = playerStore (seProgress se) (BC.unpack player)
                      , seVisitor = T.pack (BC.unpack player)
                      , seNewVisitor = existing == Nothing
                      , seAgent = agent, seBrowser = browser }
          cookie = [("Set-Cookie", identityCookie policy player) | existing == Nothing]
          options = WS.defaultConnectionOptions
            { WS.connectionFramePayloadSizeLimit = WS.SizeLimit (fromIntegral (cfgMessageBytes (seConfig se)))
            , WS.connectionMessageDataSizeLimit = WS.SizeLimit (fromIntegral (cfgMessageBytes (seConfig se))) }
      cors (websocketsOr options (wsApp scoped) (serve (Proxy :: Proxy Api) (server scoped))) req $ \res -> do
        -- One event per document served, which is every visitor including
        -- the ones that never run the bundle. The SPA fallback answers any
        -- unknown path with HTML; analytics maps these to a fixed category.
        -- Looking at the dashboard is not a visit and must not show up as
        -- one; it is also the only page whose reader is already known.
        when (isDocument res && isPage req && not (onDashboard req)) (recordLoad scoped req)
        respond (mapResponseHeaders (cookie ++) res)
 where
  cors | cfgDev (seConfig se) = addHeaders [("Access-Control-Allow-Origin", "*")]
       | otherwise = id
  isDocument res = maybe False (BS.isPrefixOf "text/html")
    (lookup hContentType (responseHeaders res))

smallBody :: Request -> Bool
smallBody req = case lookup hContentLength (requestHeaders req) of
  Just v | [(n, "")] <- reads (BC.unpack v) -> (n :: Int) <= 2048
  _ -> False

recordLoad :: ServerEnv -> Request -> IO ()
recordLoad se req = do
  let hs = requestHeaders req
      (agent, browser) = classifyAgent (fromMaybe "" (lookup hUserAgent hs))
  ev <- newEvent "load" (seVisitor se) (seNewVisitor se)
  emit (seAnalytics se) ev
    { evPath = "/" <> T.intercalate "/" (pathInfo req)
    , evCountry = clientCountry (seAnalytics se) req
    , evRef = refererHost (fromMaybe "" (lookup hReferer hs))
    , evAgent = agent
    , evBrowser = browser
    }

-- | The beacon. Rejected unless the browser says it came from us, ignored
-- unless the visitor already had a cookie (so a cookie-less flood cannot
-- invent visitors), and rate limited globally.
hit :: ServerEnv -> Maybe Text -> Hit -> Handler Value
hit se origin h = do
  let expected = T.pack (cfgOriginString (seConfig se))
  unless (cfgDev (seConfig se) || origin == Just expected) (throwError err403)
  liftIO $ when (not (seNewVisitor se)) $ do
    allowed <- spend (seHitBudget se)
    when allowed $ do
      ev <- newEvent (if hiHeartbeat h then "heartbeat" else "route") (seVisitor se) False
      emit (seAnalytics se) ev
        { evPath = hiRoute h, evLang = hiLang h
        , evAgent = seAgent se, evBrowser = seBrowser se }
  pure (object ["ok" .= True])

-- | A token bucket on the wall clock.
spend :: IORef (UTCTime, Int) -> IO Bool
spend ref = do
  now <- getCurrentTime
  atomicModifyIORef' ref $ \(at, n) ->
    let gained = truncate (realToFrac (diffUTCTime now at) * fromIntegral hitRate :: Double)
        n' = min hitBurst (n + gained)
    in if n' > 0 then ((now, n' - 1), True) else ((at, n'), False)

server :: ServerEnv -> Server Api
server se =
       pure (object ["ok" .= True, "levels" .= M.size (seSources se)])
  :<|> liftIO (getProgress (seProgress se))
  :<|> hit se
  :<|> (\d -> liftIO (summarise (seAnalytics se) (clampDays d)))
  :<|> pure (seManifest se)
  :<|> Tagged (spaApp se)
 where
  clampDays = max 1 . min 400 . fromMaybe 30

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
  | identity (cookiePolicy (cfgOriginString cfg)) headers == Nothing = WS.rejectRequest pending "open the site first"
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
  expected = BC.pack (cfgOriginString cfg)
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
              ev <- newEvent "open" (seVisitor se) False
              emit (seAnalytics se) ev { evLevel = key, evLang = unLangId lang, evAgent = seAgent se, evBrowser = seBrowser se }
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
    ev <- newEvent "check" (seVisitor se) False
    emit (seAnalytics se) ev
      { evLevel = ssKey s, evLang = unLangId lang, evVerdict = verdictName (crVerdict res)
      , evAgent = seAgent se, evBrowser = seBrowser se }
    when (crVerdict res == Solved) $
      void (markSolved (seProgress se) lang (ssKey s))

  verdictName = \case
    Solved -> "solved"
    Unsolved _ -> "unsolved"
    Rejected _ -> "rejected"
    Failed -> "failed"
