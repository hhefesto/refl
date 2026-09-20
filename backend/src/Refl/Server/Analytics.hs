-- | Who visited, and what they did once they were here.
--
-- The rules this module exists to keep:
--
-- * No IP address is ever written. The address is resolved to a country the
--   moment the request arrives and then dropped; the only per-browser key is
--   the opaque identity cookie the site already sets for progress.
-- * Recording must never be able to stall a prover session, so events go
--   through a bounded queue and are /dropped/ when it is full.
-- * Nothing is kept forever: files are one UTC day each and older ones are
--   deleted on the day roll.
module Refl.Server.Analytics
  ( Analytics
  , Event (..)
  , emptyEvent
  , newEvent
  , openAnalytics
  , analyticsEnabled
  , emit
  , clientCountry
  , classifyAgent
  , refererHost
  , summarise
  , aggregate
  , Sanitizer (..)
  , sanitizer
  , sanitizeEvent
  , normalizeHost
  , decodeEvents
  , activeCounts
  ) where

import           Control.Concurrent       (forkIO)
import           Control.Concurrent.MVar  (MVar, newMVar, withMVar)
import           Control.Concurrent.STM
import           Control.Exception        (SomeException, try)
import           Control.Monad            (unless, void, when)
import           Data.Aeson               (FromJSON (..), ToJSON, decodeStrict, encode, withObject, (.:), (.:?), (.!=))
import qualified Data.ByteString          as BS
import qualified Data.ByteString.Char8    as BC
import qualified Data.ByteString.Lazy     as BL
import           Data.IORef
import           Data.Char                (toLower, isAsciiLower, isDigit, isAsciiUpper)
import           Data.List                (isInfixOf, sort, sortOn, foldl')
import qualified Data.Map.Strict          as M
import           Data.Maybe               (fromMaybe, mapMaybe)
import           Data.Ord                 (Down (..))
import qualified Data.Set                 as S
import           Data.Text                (Text)
import qualified Data.Text                as T
import           Data.Time
import           GHC.Generics             (Generic)
import           System.Directory         (createDirectoryIfMissing, doesDirectoryExist,
                                           doesFileExist, listDirectory, removeFile)
import           System.FilePath          (takeBaseName, takeExtension, (</>))
import           System.IO                (IOMode (AppendMode), hPutStrLn, stderr, withFile)

import           Data.IP                  (fromSockAddr)
import qualified Data.GeoIP2              as Geo
import           Network.Wai              (Request, remoteHost)

import           Network.URI (parseURI, uriScheme, uriAuthority, uriRegName)
import           Text.Read (readMaybe)
import           Data.IP (IP)
import           Refl.Protocol
import           System.Timeout (timeout)

-- ---------------------------------------------------------------------------
-- The record on disk
-- ---------------------------------------------------------------------------

-- | One line of @analytics\/YYYY-MM-DD.jsonl@. New fields have explicit
-- defaults when reading older files. Missing classification means unknown.
data Event = Event
  { evAt      :: Text   -- ^ ISO-8601, UTC, to the second
  , evKind    :: Text   -- ^ @load@ | @route@ | @open@ | @check@
  , evVisitor :: Text   -- ^ a prefix of the identity cookie
  , evNew     :: Bool   -- ^ the browser arrived with no cookie at all
  , evPath    :: Text   -- ^ a validated route or a fixed document category
  , evLang    :: Text
  , evLevel   :: Text   -- ^ @world\/level@
  , evVerdict :: Text
  , evCountry :: Text   -- ^ ISO 3166-1 alpha-2
  , evRef     :: Text   -- ^ the referrer's host, never the whole URL
  , evAgent   :: Text   -- ^ @desktop@ | @mobile@ | @bot@
  , evBrowser :: Text
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON)

-- Missing classification is explicitly unknown, never human.
instance FromJSON Event where
  parseJSON = withObject "Event" $ \o -> Event
    <$> o .: "evAt" <*> o .: "evKind" <*> o .: "evVisitor"
    <*> o .:? "evNew" .!= False <*> o .:? "evPath" .!= ""
    <*> o .:? "evLang" .!= "" <*> o .:? "evLevel" .!= ""
    <*> o .:? "evVerdict" .!= "" <*> o .:? "evCountry" .!= ""
    <*> o .:? "evRef" .!= "" <*> o .:? "evAgent" .!= "unknown"
    <*> o .:? "evBrowser" .!= ""

emptyEvent :: Event
emptyEvent = Event "" "" "" False "" "" "" "" "" "" "" ""

-- | An event stamped now, for a visitor. The identity cookie is 64 hex
-- characters; a prefix is enough to tell visitors apart and is not the
-- bearer token. It is still a linkable browser identity, not a person count.
newEvent :: Text -> Text -> Bool -> IO Event
newEvent kind visitor isNew = do
  now <- getCurrentTime
  pure emptyEvent
    { evAt = T.pack (formatTime defaultTimeLocale "%Y-%m-%dT%H:%M:%SZ" now)
    , evKind = kind
    , evVisitor = T.take 16 visitor
    , evNew = isNew
    }

-- ---------------------------------------------------------------------------
-- The handle
-- ---------------------------------------------------------------------------

data Analytics = Analytics
  { anQueue     :: Maybe (TBQueue Event)
  , anDir       :: Maybe FilePath
  , anGeo       :: Maybe Geo.GeoDB
  , anSanitizer :: Sanitizer
  , anRetention :: Int
  , anCache     :: IORef (M.Map Int (UTCTime, Summary))
  -- The writer and the dashboard are threads of one process, and the GHC
  -- runtime refuses to open a file for reading while the same process holds
  -- it open for writing ("resource busy"). Today's file is exactly that
  -- file, so without this lock the dashboard silently reads zero for today
  -- and today is the day anyone looks at. Same idiom as ProgressStore.
  , anLock      :: MVar ()
  }

analyticsEnabled :: Analytics -> Bool
analyticsEnabled = (/= Nothing) . anDir

-- | Start recording. Without a directory this is a working no-op, which is
-- what every test and dev run uses.
openAnalytics :: Sanitizer -> Maybe FilePath -> Maybe FilePath -> Int -> IO Analytics
openAnalytics clean mdir mgeo retention = do
  cache <- newIORef M.empty
  lock <- newMVar ()
  geo <- case mgeo of
    Nothing -> pure Nothing
    Just p -> do
      r <- try (Geo.openGeoDB p)
      case r of
        Right db -> pure (Just db)
        Left (e :: SomeException) -> do
          hPutStrLn stderr ("analytics: no geolocation (" ++ p ++ "): " ++ show e)
          pure Nothing
  case mdir of
    Nothing -> pure (Analytics Nothing Nothing geo clean retention cache lock)
    Just dir -> do
      createDirectoryIfMissing True dir
      prune dir retention
      q <- newTBQueueIO 2048
      void (forkIO (writer dir retention lock q))
      pure (Analytics (Just q) (Just dir) geo clean retention cache lock)

-- | Never blocks and never throws: a full queue drops the event, because a
-- visit counter must not be able to hold up a proof check.
emit :: Analytics -> Event -> IO ()
emit an ev = case anQueue an of
  Nothing -> pure ()
  Just q -> atomically $ do
    full <- isFullTBQueue q
    unless full (writeTBQueue q (sanitizeEvent (anSanitizer an) ev))

-- | One open-append-close per burst rather than a handle held open, so the
-- dashboard can read today's file at all (see 'anLock').
writer :: FilePath -> Int -> MVar () -> TBQueue Event -> IO ()
writer dir retention lock q = do
  today <- utctDay <$> getCurrentTime
  go today False  -- the startup day is only partial
 where
  go day healthy = do
    batch <- fromMaybe [] <$> timeout 60000000
      (atomically ((:) <$> readTBQueue q <*> flushTBQueue q))
    today <- utctDay <$> getCurrentTime
    let days = M.toList (M.fromListWith (flip (++)) [(eventDay e, [e]) | e <- batch])
    result <- try $ withMVar lock $ \_ -> do
      mapM_ appendDay days
      -- Certify only a whole UTC day observed by this writer. Restarts,
      -- outages and old files without certificates suppress comparisons.
      when (today /= day && healthy && today == addDays 1 day) $
        writeFile (dir </> showGregorian day ++ ".covered") ""
      when (today /= day) (prune dir retention)
    case result of
      Left (e :: SomeException) -> do
        hPutStrLn stderr ("analytics: " ++ show e)
        go today False
      Right () -> go today (if today /= day then True else healthy)
  appendDay (day, evs) =
    withFile (dir </> showGregorian day ++ ".jsonl") AppendMode $ \h ->
      BL.hPut h (BL.concat [encode e <> "\n" | e <- evs])

eventDay :: Event -> Day
eventDay ev = fromMaybe (fromGregorian 1970 1 1) (parseDay (T.take 10 (evAt ev)))

parseDay :: Text -> Maybe Day
parseDay = parseTimeM False defaultTimeLocale "%Y-%m-%d" . T.unpack

-- | Delete whole days that have fallen out of the retention window.
prune :: FilePath -> Int -> IO ()
prune dir retention = do
  exists <- doesDirectoryExist dir
  when exists $ do
    today <- utctDay <$> getCurrentTime
    files <- listDirectory dir
    mapM_ (drop' today) [f | f <- files, takeExtension f `elem` [".jsonl", ".covered"]]
 where
  drop' today f = case parseDay (T.pack (takeBaseName f)) of
    Just d | diffDays today d >= fromIntegral retention ->
      void (try (removeFile (dir </> f)) :: IO (Either SomeException ()))
    _ -> pure ()

-- ---------------------------------------------------------------------------
-- Deriving the fields we are allowed to keep
-- ---------------------------------------------------------------------------

-- | The country of the peer, resolved now and immediately forgotten. The
-- peer is whatever 'Network.Wai.Middleware.RealIp' left in the request,
-- which is the true client only when the proxy was trusted.
clientCountry :: Analytics -> Request -> Text
clientCountry an req = fromMaybe "" $ do
  db <- anGeo an
  (ip, _) <- fromSockAddr (remoteHost req)
  either (const Nothing) Geo.geoCountryISO (Geo.findGeoData db "en" ip)

-- | @(class, browser)@. An empty user agent is a robot: no browser omits it.
classifyAgent :: BS.ByteString -> (Text, Text)
classifyAgent raw
  | BS.null raw = ("bot", "")
  | any (`isInfixOf` low) botMarks = ("bot", "")
  | any (`isInfixOf` low) mobileMarks = ("mobile", browser)
  | otherwise = ("desktop", browser)
 where
  low = map toLower (BC.unpack raw)
  botMarks =
    [ "bot", "crawl", "spider", "slurp", "curl", "wget", "python-requests"
    , "headlesschrome", "facebookexternalhit", "preview", "monitor", "scan"
    , "http-client", "go-http", "java/", "libwww", "okhttp", "phantomjs"
    , "archiver", "fetch", "feed", "validator", "lighthouse" ]
  mobileMarks = ["mobi", "android", "iphone", "ipad", "ipod"]
  -- order matters: every one of these also claims to be the next
  browser
    | "firefox" `isInfixOf` low = "Firefox"
    | "edg/" `isInfixOf` low = "Edge"
    | "opr/" `isInfixOf` low || "opera" `isInfixOf` low = "Opera"
    | "chrome" `isInfixOf` low || "chromium" `isInfixOf` low = "Chrome"
    | "safari" `isInfixOf` low = "Safari"
    | otherwise = "Other"

-- | A finite vocabulary derived from the loaded game. No attacker-controlled
-- identifier is retained simply because it has a plausible shape.
data Sanitizer = Sanitizer
  { allowedRoutes :: S.Set Text
  , allowedExercises :: S.Set (Text, Text)
  , allowedLanguages :: S.Set Text
  } deriving (Eq, Show)

-- The vocabulary is the game's own: naming a language here instead would
-- make a fourth prover's events blank out silently rather than fail loudly.
sanitizer :: [(WorldId, LevelId, LangId)] -> Sanitizer
sanitizer sources = Sanitizer (S.fromList routes) exercises languages
 where
  exercises = S.fromList [(unWorldId w <> "/" <> unLevelId l, unLangId lang) | (w,l,lang) <- sources]
  languages = S.fromList [unLangId lang | (_,_,lang) <- sources]
  worlds = S.toList (S.fromList [w | (w,_,_) <- sources])
  routes = map encodeRoute ([RWorldMap, RInventory, RDonate] ++ map RWorld worlds
    ++ [RLesson w l ml | (w,l,lang) <- sources, ml <- [Nothing, Just lang]]
    ++ [RLevel w n ml | w <- worlds,
        n <- [1 .. S.size (S.fromList [l | (w',l,_) <- sources, w == w'])],
        ml <- Nothing : [Just (LangId lang) | lang <- S.toList languages]])

sanitizeEvent :: Sanitizer -> Event -> Event
sanitizeEvent clean e = e
  { evPath = if evKind e == "load" then if evPath e `elem` ["/", "/index.html"] then evPath e else "other"
             else if S.member (evPath e) (allowedRoutes clean) then evPath e else ""
  , evLang = if S.member (evLang e) (allowedLanguages clean) then evLang e else ""
  , evLevel = if S.member (evLevel e, evLang e) (allowedExercises clean) then evLevel e else ""
  , evRef = normalizeHost (evRef e)
  , evAgent = if evAgent e `elem` ["desktop", "mobile", "bot"] then evAgent e else "unknown"
  , evBrowser = if evBrowser e `elem` ["Firefox", "Edge", "Opera", "Chrome", "Safari", "Other"] then evBrowser e else ""
  , evCountry = if T.length (evCountry e) == 2 && T.all isAsciiUpper (evCountry e) then evCountry e else ""
  , evVisitor = if T.length (evVisitor e) == 16 && T.all (`elem` ("0123456789abcdef" :: String)) (evVisitor e) then evVisitor e else ""
  , evVerdict = if evVerdict e `elem` ["solved", "unsolved", "rejected", "failed"] then evVerdict e else ""
  }

-- | Parse the URL before extracting the authority. Only public-shaped DNS
-- names survive; userinfo, ports and every other URI component are discarded.
refererHost :: BS.ByteString -> Text
refererHost raw = fromMaybe "" $ do
  uri <- parseURI (BC.unpack raw)
  if map toLower (uriScheme uri) `elem` ["http:", "https:"] then pure () else Nothing
  authority <- uriAuthority uri
  pure (normalizeHost (T.pack (uriRegName authority)))

-- Also used on historical host fields: never interpret an old malformed
-- authority as a URL or keep an IP, even when it was previously logged.
normalizeHost :: Text -> Text
normalizeHost raw
  | T.length host > 253 || length labels < 2 = ""
  | Just (_ :: IP) <- readMaybe (T.unpack host) = ""
  | not (T.any isAsciiLower (last labels)) = ""
  | all valid labels = host
  | otherwise = ""
 where
  host = T.toLower (fromMaybe raw (T.stripSuffix "." raw))
  labels = T.splitOn "." host
  valid label = not (T.null label) && T.length label <= 63
    && T.head label /= '-' && T.last label /= '-'
    && T.all (\c -> isAsciiLower c || isDigit c || c == '-') label

-- | Decode defensively, without modifying historical files.
decodeEvents :: Sanitizer -> BS.ByteString -> [Event]
decodeEvents clean = map (sanitizeEvent clean) . mapMaybe decodeStrict . BC.lines

-- | The dashboard's whole payload. Cached for thirty seconds; the dashboard refreshes each minute.
summarise :: Analytics -> Int -> IO Summary
summarise an days = do
  now <- getCurrentTime
  cached <- readIORef (anCache an)
  case M.lookup days cached of
    Just (at, s) | diffUTCTime now at < 30 && utctDay at == utctDay now -> pure s
    _ -> do
      let today = utctDay now
          first = addDays (1 - 2 * fromIntegral days) today
      events <- load an (addDays (-1) first) today
      covered <- case anDir an of
        Nothing -> pure S.empty
        Just dir -> S.fromList . mapMaybe (parseDay . T.pack . takeBaseName)
          . filter ((== ".covered") . takeExtension) <$> listDirectory dir
      let s = aggregate (anSanitizer an) now days (anRetention an)
                (analyticsEnabled an) (maybe False (const True) (anGeo an)) covered events
      atomicModifyIORef' (anCache an) (\c -> (M.insert days (now, s) c, ()))
      pure s

-- | Meaning: each UTC interval is half-open. A completion is a set member
-- (browser identity, lesson, language); checking implies opening. These
-- definitions guarantee solved <= opened and invariance under repeated checks.
-- Only positively classified browser events contribute to human metrics.
aggregate :: Sanitizer -> UTCTime -> Int -> Int -> Bool -> Bool -> S.Set Day -> [Event] -> Summary
aggregate clean now days retention enabled geo covered events = Summary
    { suDays = days, suFrom = dayText from, suTo = dayText today
    , suRetention = retention, suEnabled = enabled, suGeo = geo
    , suAsOf = T.pack (formatTime defaultTimeLocale "%Y-%m-%dT%H:%M:%SZ" now)
    , suActive = active, suPeak = maximum (0 : M.elems peaks)
    , suComparable = enabled && prevFrom >= retainedFrom
        && all (`S.member` covered) [prevFrom .. addDays (-1) today]
    , suCoveredDays = length (filter (`S.member` covered) [prevFrom .. addDays (-1) today])
    , suUnknown = length [e | e <- cur, evAgent e == "unknown"]
    , suTotals = totals cur, suPrevious = totals prev
    , suDaily = [DayPoint (dayText d) (visitors (onDay d))
        (length (kind "load" (onDay d))) (length (kind "route" (onDay d)))
        (M.findWithDefault 0 d peaks) | d <- [from .. today]]
    , suCountries = buckets evCountry loads 250
    , suPages = buckets evPath (kind "route" human) 10
    , suLevels = [LevelStat k (S.size (exercises [e | e <- opened, evLevel e == k]))
                    (S.size (exercises [e | e <- solved, evLevel e == k]))
                 | k <- S.toList (S.fromList (map evLevel opened)), not (T.null k)]
    , suLanguages = rank [lang | (_,_,lang) <- S.toList (exercises opened)] 10
    , suReferrers = buckets evRef loads 10
    , suAgents = buckets evAgent (kind "load" cur) 5
    , suBrowsers = buckets evBrowser loads 8
    }
 where
  today = utctDay now
  from = addDays (1 - fromIntegral days) today
  prevFrom = addDays (negate (fromIntegral days)) from
  retainedFrom = addDays (1 - fromIntegral retention) today
  stamped = [(t,e) | raw <- events, let e = sanitizeEvent clean raw,
              Just t <- [parseTimeM False defaultTimeLocale "%Y-%m-%dT%H:%M:%SZ" (T.unpack (evAt e)) :: Maybe UTCTime],
              t <= now, utctDay t >= retainedFrom]
  window a b = [e | (t,e) <- stamped, t >= UTCTime a 0, t < UTCTime b 0]
  cur = window from (addDays 1 today)
  prev = window prevFrom from
  (active, peaks) = activeCounts now from [(t,evVisitor e) | (t,e) <- stamped,
    isHuman e, not (T.null (evVisitor e)),
    evKind e `elem` ["load", "open", "check"] ||
      (evKind e `elem` ["route", "heartbeat"] && not (T.null (evPath e)))]
  human = filter isHuman cur
  loads = kind "load" human
  opened = [e | e <- human, evKind e `elem` ["open", "check"]]
  solved = [e | e <- human, evKind e == "check", evVerdict e == "solved"]
  onDay d = [e | e <- human, T.take 10 (evAt e) == dayText d]
  dayText = T.pack . showGregorian
  kind k = filter (\e -> evKind e == k && (k /= "route" || not (T.null (evPath e))))
  isHuman e = evAgent e `elem` ["desktop", "mobile"]
  distinct = S.size . S.fromList . filter (not . T.null)
  visitors = distinct . map evVisitor
  exercises es = S.fromList [(evVisitor e, evLevel e, evLang e) | e <- es,
    not (T.null (evVisitor e)), not (T.null (evLevel e)), not (T.null (evLang e))]
  totals es = let nb = filter isHuman es; ld = kind "load" nb in Totals
    { toVisitors = visitors nb
    , toNew = visitors (filter evNew ld)
    , toLoads = length ld, toViews = length (kind "route" nb)
    , toCountries = distinct (map evCountry ld)
    , toSolves = S.size (exercises [e | e <- nb, evKind e == "check", evVerdict e == "solved"])
    , toBots = length [e | e <- es, evKind e == "load", evAgent e == "bot"] }
  buckets field es = rank (filter (not . T.null) (map field es))
  rank keys n =
    let sorted = sortOn (\(k,c) -> (Down c,k))
          (M.toList (M.fromListWith (+) [(k,1 :: Int) | k <- keys]))
        (top,rest) = splitAt n sorted
        other = sum (map snd rest)
    in [Bucket k k c | (k,c) <- top] ++ [Bucket "other" "Other" other | other > 0]

-- | Each activity extends one browser's presence to [t, t + 5 minutes).
-- Union intervals per browser before counting their overlaps: repeated tabs,
-- heartbeats and simultaneous actions can never count the same browser twice.
-- Include midnight boundaries so a browser active across midnight contributes
-- to the next day's peak even before its next heartbeat.
activeCounts :: UTCTime -> Day -> [(UTCTime, Text)] -> (Int, M.Map Day Int)
activeCounts now from observations = (current, peaks)
 where
  first = UTCTime from 0
  grouped = M.fromListWith (++) [(visitor,[t]) | (t,visitor) <- observations,
    not (T.null visitor), t <= now, addUTCTime 300 t > first]
  intervals = concatMap (merge . sort) (M.elems grouped)
  merge [] = []
  merge (t:ts) = go t (addUTCTime 300 t) ts
  go start end [] = [(start,end)]
  go start end (t:ts)
    | t <= end = go start (addUTCTime 300 t) ts
    | otherwise = (start,end) : go t (addUTCTime 300 t) ts
  changes = M.fromListWith (+)
    ([(t,delta) | (start,end) <- intervals, (t,delta) <- [(start,1),(end,-1)], t <= now]
     ++ [(UTCTime d 0,0) | d <- [from .. utctDay now]])
  (current, peaks) = foldl' step (0,M.empty) (M.toAscList changes)
  step (count, days) (at,delta) =
    let count' = count + delta
    in (count', if at < first then days else M.insertWith max (utctDay at) count' days)

-- | Every retained event in @[from, to]@. A damaged line is skipped, not
-- fatal: a half-written last line after a kill must not blank the dashboard.
-- A day that is simply absent is normal; anything else is reported, because
-- a dashboard that silently reads zero looks exactly like no visitors.
load :: Analytics -> Day -> Day -> IO [Event]
load an from to = case anDir an of
  Nothing -> pure []
  Just dir -> withMVar (anLock an) (const (concat <$> mapM (readDay dir) [from .. to]))
 where
  readDay dir d = do
    let path = dir </> showGregorian d ++ ".jsonl"
    there <- doesFileExist path
    if not there then pure [] else do
      r <- try (BS.readFile path)
      case r of
        Left (e :: SomeException) -> do
          hPutStrLn stderr ("analytics: cannot read " ++ path ++ ": " ++ show e)
          pure []
        Right bs -> do
          let ls = filter (not . BS.null) (BC.lines bs)
              evs = decodeEvents (anSanitizer an) bs
          when (length evs /= length ls) $
            hPutStrLn stderr ("analytics: " ++ show (length ls - length evs)
                              ++ " unreadable line(s) in " ++ path)
          pure evs
