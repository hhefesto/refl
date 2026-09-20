-- | What the dashboard is told. Aggregates only: the server never keeps an
-- IP address, and the visitor key is the opaque identity cookie the site
-- already sets, so nothing here identifies a person.
module Refl.Protocol.Stats where

import           Data.Aeson   (FromJSON, ToJSON)
import           Data.Text    (Text)
import           GHC.Generics (Generic)

-- | What the SPA reports on a route change. Hash routes never reach the
-- server, so without this the only thing recorded would be the first
-- document load.
data Hit = Hit
  { hiRoute :: Text
  , hiLang  :: Text
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

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
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

-- | Opened versus solved is the only number that says whether the game
-- teaches, so levels get their own shape rather than a 'Bucket'.
data LevelStat = LevelStat
  { lvKey    :: Text     -- ^ @world/level@
  , lvOpened :: Int
  , lvSolved :: Int
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data Totals = Totals
  { toVisitors :: Int   -- ^ distinct identities, bots excluded
  , toNew      :: Int   -- ^ arrived without a cookie
  , toLoads    :: Int   -- ^ documents served (every visitor, JS or not)
  , toViews    :: Int   -- ^ in-app navigations (JS only)
  , toCountries :: Int
  , toSolves   :: Int
  , toBots     :: Int   -- ^ loads classed as crawlers, kept out of the rest
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

emptyTotals :: Totals
emptyTotals = Totals 0 0 0 0 0 0 0

data Summary = Summary
  { suDays      :: Int    -- ^ the window, in days
  , suFrom      :: Text
  , suTo        :: Text
  , suRetention :: Int    -- ^ how long events are kept at all
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
