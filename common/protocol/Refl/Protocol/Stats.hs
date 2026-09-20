-- | What the dashboard is told. Aggregates only: the server never keeps an
-- IP address, and the visitor key is the opaque identity cookie the site
-- already sets, so nothing here identifies a person.
module Refl.Protocol.Stats where

import           Data.Aeson   (FromJSON (..), ToJSON, withObject, (.:), (.:?), (.!=))
import           Data.Text    (Text)
import           GHC.Generics (Generic)

-- | What the SPA reports on a route change. Hash routes never reach the
-- server, so without this the only thing recorded would be the first
-- document load.
data Hit = Hit
  { hiRoute :: Text
  , hiLang  :: Text
  , hiHeartbeat :: Bool -- ^ presence only; never an in-app navigation
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON)

instance FromJSON Hit where
  parseJSON = withObject "Hit" $ \o -> Hit <$> o .: "hiRoute" <*> o .: "hiLang" <*> o .:? "hiHeartbeat" .!= False

-- | One ranked row of a breakdown. 'buKey' is the machine value (an ISO
-- country code, a route, a language id); 'buLabel' is what to print.
data Bucket = Bucket
  { buKey   :: Text
  , buLabel :: Text
  , buCount :: Int
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data DayPoint = DayPoint
  { dpDay      :: Text   -- ^ @YYYY-MM-DD@, UTC
  , dpVisitors :: Int
  , dpLoads    :: Int
  , dpViews    :: Int
  , dpPeak     :: Int   -- ^ peak distinct browser identities active within five minutes
  , dpSessions :: Int   -- ^ peak prover sessions held at once that day
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

-- | Distinct browser-language pairs per lesson in this period. Every check
-- establishes an opening; completions are a subset of openings.
data LevelStat = LevelStat
  { lvKey    :: Text     -- ^ @world/level@
  , lvOpened :: Int
  , lvSolved :: Int
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data Totals = Totals
  { toVisitors :: Int   -- ^ distinct identities, bots excluded
  , toNew      :: Int   -- ^ arrived without a cookie
  , toLoads    :: Int   -- ^ document loads from classified browsers, JS or not
  , toViews    :: Int   -- ^ in-app navigations (JS only)
  , toCountries :: Int
  , toSolves   :: Int   -- ^ distinct (browser, lesson, language) completions
  , toBots     :: Int   -- ^ loads classed as crawlers, kept out of the rest
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

emptyTotals :: Totals
emptyTotals = Totals 0 0 0 0 0 0 0

data Summary = Summary
  { suDays      :: Int    -- ^ the window, in days
  , suFrom      :: Text
  , suTo        :: Text
  , suAsOf      :: Text   -- ^ snapshot time, UTC
  , suActive    :: Int    -- ^ distinct browser identities active within five minutes
  , suPeak      :: Int    -- ^ highest five-minute concurrency in the selected period
  , suRetention :: Int    -- ^ how long events are kept at all
  , suEnabled   :: Bool   -- ^ collection is enabled
  , suComparable :: Bool  -- ^ both periods have recorded history
  , suCoveredDays :: Int  -- ^ complete UTC days in the two periods
  , suUnknown   :: Int    -- ^ unclassified legacy events, excluded from human metrics
  -- A reader costs nothing; a prover session costs a process, and there are
  -- only 'suSessionsMax' of those. These four are the capacity picture:
  -- what is held now, the most ever held at once, and who was turned away.
  , suSessions    :: Int -- ^ prover sessions open at the snapshot
  , suSessionsMax :: Int -- ^ the configured ceiling (--max-sessions)
  , suSessionPeak :: Int -- ^ most prover sessions held at once in the period
  , suRejected    :: Int -- ^ connections refused because the ceiling was reached
  , suGeo       :: Bool   -- ^ whether a geolocation database is loaded
  , suTotals    :: Totals
  , suPrevious  :: Totals -- ^ the window before this one, for the deltas
  , suDaily     :: [DayPoint]
  , suCountries :: [Bucket]
  , suPages     :: [Bucket]
  , suLevels    :: [LevelStat]
  , suLanguages :: [Bucket]
  , suReferrers :: [Bucket]
  , suAgents    :: [Bucket]
  , suBrowsers  :: [Bucket]
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)
