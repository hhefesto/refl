-- | Who visited, and what they did once they were here.
--
-- The rules this module exists to keep:
--
-- * No IP address is ever written. The address is resolved to a country the
--   moment the request arrives and then dropped; the only per-person key is
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
  ) where

import           Control.Concurrent       (forkIO)
import           Control.Concurrent.MVar  (MVar, newMVar, withMVar)
import           Control.Concurrent.STM
import           Control.Exception        (SomeException, try)
import           Control.Monad            (unless, void, when)
import           Data.Aeson               (FromJSON, ToJSON, decodeStrict, encode)
import qualified Data.ByteString          as BS
import qualified Data.ByteString.Char8    as BC
import qualified Data.ByteString.Lazy     as BL
import           Data.IORef
import           Data.Char                (toLower)
import           Data.List                (isInfixOf, sortOn)
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

import           Refl.Protocol.Stats

-- ---------------------------------------------------------------------------
-- The record on disk
-- ---------------------------------------------------------------------------

-- | One line of @analytics\/YYYY-MM-DD.jsonl@. Every field is always
-- present and empty means absent, so folding a day never has to reason
-- about missing keys and an older file still reads after a field is added.
data Event = Event
  { evAt      :: Text   -- ^ ISO-8601, UTC, to the second
  , evKind    :: Text   -- ^ @load@ | @route@ | @open@ | @check@
  , evVisitor :: Text   -- ^ a prefix of the identity cookie
  , evNew     :: Bool   -- ^ the browser arrived with no cookie at all
  , evPath    :: Text   -- ^ load: the request path; route: the hash route
  , evLang    :: Text
  , evLevel   :: Text   -- ^ @world\/level@
  , evVerdict :: Text
  , evCountry :: Text   -- ^ ISO 3166-1 alpha-2
  , evRef     :: Text   -- ^ the referrer's host, never the whole URL
  , evAgent   :: Text   -- ^ @desktop@ | @mobile@ | @bot@
  , evBrowser :: Text
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

emptyEvent :: Event
emptyEvent = Event "" "" "" False "" "" "" "" "" "" "" ""

-- | An event stamped now, for a visitor. The identity cookie is 64 hex
-- characters; a prefix is enough to tell visitors apart and is not the
-- bearer token, so the log is useless to anyone who reads it.
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
openAnalytics :: Maybe FilePath -> Maybe FilePath -> Int -> IO Analytics
openAnalytics mdir mgeo retention = do
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
    Nothing -> pure (Analytics Nothing Nothing geo retention cache lock)
    Just dir -> do
      createDirectoryIfMissing True dir
      prune dir retention
      q <- newTBQueueIO 2048
      void (forkIO (writer dir retention lock q))
      pure (Analytics (Just q) (Just dir) geo retention cache lock)

-- | Never blocks and never throws: a full queue drops the event, because a
-- visit counter must not be able to hold up a proof check.
emit :: Analytics -> Event -> IO ()
emit an ev = case anQueue an of
  Nothing -> pure ()
  Just q -> atomically $ do
    full <- isFullTBQueue q
    unless full (writeTBQueue q ev)

-- | One open-append-close per burst rather than a handle held open, so the
-- dashboard can read today's file at all (see 'anLock').
writer :: FilePath -> Int -> MVar () -> TBQueue Event -> IO ()
writer dir retention lock q = go Nothing
 where
  go lastDay = do
    batch <- atomically ((:) <$> readTBQueue q <*> flushTBQueue q)
    let days = M.toList (M.fromListWith (flip (++)) [(eventDay e, [e]) | e <- batch])
        newest = maximum (map fst days)
    r <- try (withMVar lock (const (mapM_ appendDay days)))
    case r of
      Right () -> pure ()
      Left (e :: SomeException) -> hPutStrLn stderr ("analytics: " ++ show e)
    -- a new day: retire what fell out of the window while we ran
    when (lastDay /= Nothing && lastDay /= Just newest) (prune dir retention)
    go (Just newest)
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
    mapM_ (drop' today) [f | f <- files, takeExtension f == ".jsonl"]
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

-- | Only the host. A full referrer URL can carry a query string, which can
-- carry anything at all.
refererHost :: BS.ByteString -> Text
refererHost raw = case T.splitOn "/" (T.strip (dropScheme (T.pack (BC.unpack raw)))) of
  h : _ | not (T.null h) -> T.takeWhile (/= ':') h
  _ -> ""
 where
  dropScheme t = foldr (\p acc -> maybe acc id (T.stripPrefix p t)) t ["http://", "https://"]

-- ---------------------------------------------------------------------------
-- Reading it back
-- ---------------------------------------------------------------------------

-- | The dashboard's whole payload. Memoised for a minute: the endpoint is
-- behind a password, but it should still not be a way to spin the disk.
summarise :: Analytics -> Int -> IO Summary
summarise an days = do
  now <- getCurrentTime
  cached <- readIORef (anCache an)
  case M.lookup days cached of
    Just (at, s) | diffUTCTime now at < 60 -> pure s
    _ -> do
      s <- build an days now
      modifyIORef' (anCache an) (M.insert days (now, s))
      pure s

build :: Analytics -> Int -> UTCTime -> IO Summary
build an days now = do
  let today = utctDay now
      from = addDays (negate (fromIntegral days - 1)) today
      prevFrom = addDays (negate (2 * fromIntegral days - 1)) today
      prevTo = addDays (-1) from
  cur <- load an from today
  prev <- load an prevFrom prevTo
  let nonBot = [e | e <- cur, evAgent e /= "bot"]
      loads = [e | e <- nonBot, evKind e == "load"]
      routes = [e | e <- nonBot, evKind e == "route"]
      opens = [e | e <- nonBot, evKind e == "open"]
      solved = [e | e <- nonBot, evKind e == "check", evVerdict e == "solved"]
      dayKeys = [T.pack (showGregorian d) | d <- [from .. today]]
      byDayMap = M.fromListWith (++) [(T.take 10 (evAt e), [e]) | e <- nonBot]
      byDay k = M.findWithDefault [] k byDayMap
  pure Summary
    { suDays = days
    , suFrom = T.pack (showGregorian from)
    , suTo = T.pack (showGregorian today)
    , suRetention = anRetention an
    , suGeo = maybe False (const True) (anGeo an)
    , suTotals = totals cur
    , suPrevious = totals prev
    , suDaily =
        [ DayPoint k (distinct (map evVisitor (byDay k)))
                     (length [e | e <- byDay k, evKind e == "load"])
                     (length [e | e <- byDay k, evKind e == "route"])
        | k <- dayKeys ]
    , suCountries = rank [(evCountry e, evCountry e) | e <- loads, not (T.null (evCountry e))] 250
    , suPages = rank [(evPath e, evPath e) | e <- routes, not (T.null (evPath e))] 10
    , suLevels =
        [ LevelStat k (length [() | e <- opens, evLevel e == k])
                      (length [() | e <- solved, evLevel e == k])
        | k <- uniq (map evLevel (opens ++ solved)), not (T.null k) ]
    , suLanguages = rank [(evLang e, evLang e) | e <- opens, not (T.null (evLang e))] 10
    , suReferrers = rank [(evRef e, evRef e) | e <- loads, not (T.null (evRef e))] 10
    , suAgents = rank [(evAgent e, evAgent e) | e <- cur, evKind e == "load"] 5
    , suBrowsers = rank [(evBrowser e, evBrowser e) | e <- loads, not (T.null (evBrowser e))] 8
    }
 where
  totals es =
    let nb = [e | e <- es, evAgent e /= "bot"]
        ld = [e | e <- nb, evKind e == "load"]
    in Totals
      { toVisitors = distinct (map evVisitor nb)
      , toNew = length [e | e <- ld, evNew e]
      , toLoads = length ld
      , toViews = length [e | e <- nb, evKind e == "route"]
      , toCountries = distinct [evCountry e | e <- ld, not (T.null (evCountry e))]
      , toSolves = length [e | e <- nb, evKind e == "check", evVerdict e == "solved"]
      , toBots = length [e | e <- es, evKind e == "load", evAgent e == "bot"]
      }
  distinct = S.size . S.fromList
  uniq = S.toList . S.fromList
  -- ranked, with everything past the cut folded into one honest row
  rank pairs n =
    let counted = M.toList (M.fromListWith (+) [(k, 1 :: Int) | (k, _) <- pairs])
        labels = M.fromList pairs
        sorted = sortOn (\(k, c) -> (Down c, k)) counted
        (top, rest) = splitAt n sorted
        other = sum (map snd rest)
    in [ Bucket k (M.findWithDefault k k labels) c | (k, c) <- top ]
       ++ [ Bucket "other" "Other" other | other > 0 ]

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
              evs = mapMaybe decodeStrict ls
          when (length evs /= length ls) $
            hPutStrLn stderr ("analytics: " ++ show (length ls - length evs)
                              ++ " unreadable line(s) in " ++ path)
          pure evs
