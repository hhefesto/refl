module AnalyticsSpec (spec) where

import Control.Exception (bracket)
import Control.Monad (forM_)
import Data.Aeson (encode, decodeStrict)
import qualified Data.Map.Strict as M
import qualified Data.ByteString.Char8 as BC
import qualified Data.ByteString.Lazy as BL
import qualified Data.Set as S
import qualified Data.Text.Encoding as TE
import Data.Time
import Network.HTTP.Types
import Network.Socket (SockAddr (..), tupleToHostAddress)
import Network.Wai
import Network.Wai.Test
import Refl.Protocol
import Refl.Server.Access
import Refl.Server.Analytics
import System.Directory
import System.FilePath ((</>))
import System.IO
import Test.Hspec

clean :: Sanitizer
clean = sanitizer [(WorldId "tutorial", LevelId "refl", LangId l) | l <- ["agda", "lean"]]

now :: UTCTime
now = UTCTime (fromGregorian 2026 9 20) 43200

sample :: Event
sample = emptyEvent { evAt = "2026-09-20T00:00:00Z", evKind = "check"
  , evVisitor = "0123456789abcdef", evLevel = "tutorial/refl", evLang = "agda"
  , evVerdict = "solved", evAgent = "desktop" }

summary :: [Event] -> Summary
summary = aggregate clean now 30 400 True False S.empty

withDir :: (FilePath -> IO a) -> IO a
withDir = bracket create removePathForcibly
 where
  create = do
    tmp <- getTemporaryDirectory
    (p,h) <- openTempFile tmp "refl-analytics-test"
    hClose h
    removeFile p
    createDirectory p
    pure p

spec :: Spec
spec = do
  describe "analytics privacy boundary" $ do
    it "parses referrers and retains only normalized DNS hosts" $ do
      refererHost "https://alice:secret@WWW.Example.COM.:8443/path?token=secret#frag" `shouldBe` "www.example.com"
      forM_ ["https://192.0.2.1/x", "http://[2001:db8::1]/", "192.0.2.1", "alice@example.org?secret", "https://example.org token", "//example.org/", "https://example.org%2fsecret/", "javascript:secret"] $ \url ->
        refererHost url `shouldBe` ""
    it "sanitizes arbitrary document paths, routes, languages and legacy authorities" $ do
      let e = sanitizeEvent clean sample { evKind = "load", evPath = "/alice/token", evRef = "alice:secret@example.org", evLang = "secret" }
      evPath e `shouldBe` "other"
      evRef e `shouldBe` ""
      evLang e `shouldBe` ""
      evLevel e `shouldBe` ""
      evPath (sanitizeEvent clean sample { evKind = "route", evPath = "#/w/private-user" }) `shouldBe` ""
      evPath (sanitizeEvent clean sample { evKind = "route", evPath = "#/w/tutorial/level/refl/agda" }) `shouldBe` "#/w/tutorial/level/refl/agda"
    it "excludes bots across document, beacon, open and check events" $ do
      let (agent,_) = classifyAgent "SyntheticBot/1"
          s = summary [sample { evAgent = agent, evKind = k, evPath = "#/" } | k <- ["load", "route", "open", "check"]]
      toVisitors (suTotals s) `shouldBe` 0
      toSolves (suTotals s) `shouldBe` 0
      toBots (suTotals s) `shouldBe` 1
      suLevels s `shouldBe` []
    it "reads legacy defaults, skips corrupt lines, and labels unclassified events" $ do
      let old = "{\"evAt\":\"2026-09-20T00:00:00Z\",\"evKind\":\"load\",\"evVisitor\":\"0123456789abcdef\",\"evPath\":\"/secret\",\"evRef\":\"192.0.2.1\"}\n"
          events = decodeEvents clean (old <> "{damaged\n" <> BL.toStrict (encode sample) <> "\n")
      length events `shouldBe` 2
      evAgent (head events) `shouldBe` "unknown"
      evRef (head events) `shouldBe` ""
      evPath (head events) `shouldBe` "other"
      suUnknown (summary events) `shouldBe` 1
      toLoads (suTotals (summary events)) `shouldBe` 0
  describe "analytics meaning" $ do
    it "rechecking is idempotent and a check establishes an opening" $ do
      let s = summary (replicate 10 sample)
      toSolves (suTotals s) `shouldBe` 1
      suLevels s `shouldBe` [LevelStat "tutorial/refl" 1 1]
    it "counts separate players and languages as separate exercises" $ do
      let s = summary [sample, sample { evLang = "lean" }, sample { evVisitor = "abcdef0123456789" }]
      toVisitors (suTotals s) `shouldBe` 2
      toSolves (suTotals s) `shouldBe` 3
      suLevels s `shouldBe` [LevelStat "tutorial/refl" 3 3]
    it "uses exact UTC period boundaries and ignores future or invalid timestamps" $ do
      let s = summary [sample { evAt = t } | t <- ["2026-08-22T00:00:00Z", "2026-08-21T23:59:59Z", "2026-09-20T12:00:01Z", "invalid"]]
      toSolves (suTotals s) `shouldBe` 1
      toSolves (suPrevious s) `shouldBe` 1
      dpVisitors (head (suDaily s)) `shouldBe` 1
    it "deduplicates completions across days but keeps loads and navigations separate" $ do
      let s = summary [sample, sample { evAt = "2026-09-19T00:00:00Z" }, sample { evKind = "load" }, sample { evKind = "route", evPath = "#/" }]
      toSolves (suTotals s) `shouldBe` 1
      toLoads (suTotals s) `shouldBe` 1
      toViews (suTotals s) `shouldBe` 1
    it "does not let malformed exercises or identities contribute completions" $ do
      let s = summary [sample { evLevel = "secret" }, sample { evLang = "secret" }, sample { evVisitor = "" }]
      toSolves (suTotals s) `shouldBe` 0
      all (\l -> lvSolved l <= lvOpened l) (suLevels s) `shouldBe` True
    it "suppresses comparisons with any missing coverage, including a 400-day year" $ do
      let today = utctDay now
          full = S.fromList [addDays (-59) today .. addDays (-1) today]
          run n cov = aggregate clean now n 400 True False cov []
      suComparable (run 30 full) `shouldBe` True
      suComparable (run 30 (S.delete (addDays (-40) today) full)) `shouldBe` False
      suComparable (run 365 (S.fromList [addDays (-399) today .. today])) `shouldBe` False
    it "prunes expired files without rewriting retained or malformed files" $ withDir $ \dir -> do
      today <- utctDay <$> getCurrentTime
      let old = dir </> showGregorian (addDays (-400) today) ++ ".jsonl"
          kept = dir </> showGregorian (addDays (-399) today) ++ ".jsonl"
      BC.writeFile old "old"
      BC.writeFile kept "corrupt but preserved"
      _ <- openAnalytics clean (Just dir) Nothing 400
      doesFileExist old `shouldReturn` False
      BC.readFile kept `shouldReturn` "corrupt but preserved"
    it "reports disabled collection explicitly" $ do
      an <- openAnalytics clean Nothing Nothing 400
      suEnabled <$> summarise an 30 `shouldReturn` False
  describe "five-minute browser concurrency" $ do
    let day = utctDay now
        at seconds = UTCTime day seconds
        run = activeCounts (at 1000) day
    it "deduplicates repeated activity and multiple tabs, expiring at five minutes" $ do
      let (active,peaks) = run [(at 800,"a"),(at 800,"a"),(at 900,"a"),(at 701,"b"),(at 700,"expired")]
      active `shouldBe` 2
      M.lookup day peaks `shouldBe` Just 3
    it "counts a daily peak rather than summing non-overlapping browsers" $ do
      let (active,peaks) = run [(at 0,"a"),(at 301,"b"),(at 602,"c")]
      active `shouldBe` 0
      M.lookup day peaks `shouldBe` Just 1
    it "treats simultaneous expiry and arrival as half-open intervals" $ do
      let (_,peaks) = run [(at 0,"a"),(at 300,"b")]
      M.lookup day peaks `shouldBe` Just 1
    it "carries an active browser across UTC midnight and rejects future activity" $ do
      let previous = addUTCTime (-100) (at 0)
          (active,peaks) = activeCounts (at 100) day [(previous,"a"),(at 50,"b"),(at 101,"future")]
      active `shouldBe` 2
      M.lookup day peaks `shouldBe` Just 2
    it "keeps heartbeats separate from loads, navigations and completions" $ do
      let beat = sample { evKind = "heartbeat", evPath = "#/", evAt = "2026-09-20T11:59:00Z" }
          s = summary [beat,beat,beat { evVisitor = "abcdef0123456789" }, beat { evAgent = "bot", evVisitor = "aaaaaaaaaaaaaaaa" }]
      suActive s `shouldBe` 2
      suPeak s `shouldBe` 2
      toViews (suTotals s) `shouldBe` 0
      toLoads (suTotals s) `shouldBe` 0
      toSolves (suTotals s) `shouldBe` 0
      dpPeak (last (suDaily s)) `shouldBe` 2
    it "reads old beacons as navigations" $ do
      decodeStrict "{\"hiRoute\":\"#/\",\"hiLang\":\"agda\"}" `shouldBe` Just (Hit "#/" "agda" False)
  describe "prover capacity" $ do
    let held at seconds = sample { evKind = "session", evAt = at, evSeconds = seconds }
    it "counts sessions that overlap, not sessions that merely happened" $ do
      -- three held for a minute from the same instant, then one alone
      let s = summary ([(held "2026-09-20T10:01:00Z" 60) { evVisitor = v }
                       | v <- ["0123456789abcdef", "abcdef0123456789", "aaaabbbbccccdddd"]]
                       ++ [held "2026-09-20T11:00:00Z" 60])
      suSessionPeak s `shouldBe` 3
      dpSessions (last (suDaily s)) `shouldBe` 3
    it "does not union a browser's own sessions: two tabs hold two slots" $ do
      let s = summary [held "2026-09-20T10:01:00Z" 60, held "2026-09-20T10:01:30Z" 60]
      suSessionPeak s `shouldBe` 2
    it "counts refusals, and keeps them out of the human metrics" $ do
      let s = summary [sample { evKind = "capacity", evAt = "2026-09-20T10:00:00Z" }
                      , sample { evKind = "capacity", evAt = "2026-09-20T10:00:01Z" }]
      suRejected s `shouldBe` 2
      toLoads (suTotals s) `shouldBe` 0
      toViews (suTotals s) `shouldBe` 0
      toSolves (suTotals s) `shouldBe` 0
    it "leaves the live pair to the server, which is the only thing that knows it" $ do
      let s = summary [held "2026-09-20T10:01:00Z" 60]
      (suSessions s, suSessionsMax s) `shouldBe` (0, 0)
    it "refuses a duration long enough to bend the chart" $ do
      evSeconds (sanitizeEvent clean (held "2026-09-20T10:00:00Z" 99999999)) `shouldBe` 86400
      evSeconds (sanitizeEvent clean (held "2026-09-20T10:00:00Z" (-5))) `shouldBe` 0
    it "carries a session that spans midnight into both days" $ do
      let s = summary [held "2026-09-20T00:10:00Z" 1200]
      dpSessions (last (suDaily s)) `shouldBe` 1
      lookup "2026-09-19" [(dpDay d, dpSessions d) | d <- suDaily s] `shouldBe` Just 1
  describe "dashboard access" $ do
    it "rejects empty and whitespace-only password files without echoing the secret" $ withDir $ \dir -> do
      forM_ ["", " \t\n", "\nnonempty", TE.encodeUtf8 "\x2003\x2002"] $ \pw -> do
        BC.writeFile (dir </> "password") pw
        readSecret (dir </> "password") `shouldThrow` anyIOException
      BC.writeFile (dir </> "password") "test-password\n"
      readSecret (dir </> "password") `shouldReturn` "test-password"
    it "protects every dashboard path and every response from caching" $ do
      let inner _ respond = respond (responseLBS status200 [("Cache-Control", "public")] "ok")
          get pw path auth = runSession (request ((setPath defaultRequest path) { requestHeaders = auth })) (dashboardAuth pw inner)
      forM_ ["/dashboard", "/dashboard/", "/dashboard/data.json", "/dashboard/unknown"] $ \path -> do
        forM_ [(Nothing, [], status403), (Just "test", [], status401), (Just "test", [("Authorization", "Basic cmVmbDp3cm9uZw==")], status401), (Just "test", [("Authorization", "Basic cmVmbDp0ZXN0")], status200), (Just "", [("Authorization", "Basic cmVmbDo=")], status401)] $ \(pw,auth,status) -> do
          res <- get pw path auth
          simpleStatus res `shouldBe` status
          lookup "Cache-Control" (simpleHeaders res) `shouldBe` Just "private, no-store"
          lookup "Set-Cookie" (simpleHeaders res) `shouldBe` Nothing
      simpleStatus <$> get Nothing "/" [] `shouldReturn` status200
    it "trusts only configured proxy peers, never private networks by default" $ do
      let peer ip = SockAddrInet 1234 (tupleToHostAddress ip)
          original = peer (10,0,0,2)
          run ranges remote = do
            middleware <- either fail pure (proxyHeaders ranges)
            runSession (request defaultRequest { remoteHost = remote, requestHeaders = [("X-Real-IP", "203.0.113.4")] })
              (middleware (\req respond -> respond (responseLBS status200 [] (BL.fromStrict (BC.pack (show (remoteHost req)))))))
      untouched <- run [] original
      simpleBody untouched `shouldBe` BL.fromStrict (BC.pack (show original))
      spoof <- run ["127.0.0.1/32"] original
      simpleBody spoof `shouldBe` simpleBody untouched
      trusted <- run ["10.0.0.2/32"] original
      simpleBody trusted `shouldSatisfy` (BC.isInfixOf "203.0.113.4" . BL.toStrict)
