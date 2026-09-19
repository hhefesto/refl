-- | Server configuration: CLI flags with @REFL_*@ environment fallbacks, so
-- the same binary runs from the nix wrapper and from the dev shell.
module Refl.Config
  ( Config (..)
  , defaultDataDir
  , envFromConfig
  ) where

import           System.Directory (getXdgDirectory, XdgDirectory (XdgData))
import           System.FilePath  ((</>))

import           Refl.Language    (Env (..))

data Config = Config
  { cfgWww      :: Maybe FilePath   -- ^ static site to serve; Nothing = API only
  , cfgGames    :: FilePath         -- ^ games/<game> directory
  , cfgPort     :: Int
  , cfgHost     :: String
  , cfgDev      :: Bool             -- ^ permissive CORS for the jsaddle-warp dev client
  , cfgDataDir  :: Maybe FilePath   -- ^ where progress.json lives
  , cfgWorkDir  :: Maybe FilePath   -- ^ per-session prover directories
  , cfgAgda     :: FilePath
  , cfgAgdaDir  :: Maybe FilePath
  , cfgLean     :: Maybe FilePath
  , cfgLeanPath :: Maybe FilePath
  , cfgBend     :: Maybe FilePath
  , cfgBendPath :: Maybe FilePath
  , cfgVerbose  :: Bool
  , cfgOrigin :: Maybe String
  , cfgMaxSessions :: Int
  , cfgMessageBytes :: Int
  , cfgCommandSeconds :: Int
  , cfgIdleSeconds :: Int
  } deriving (Show)

defaultDataDir :: IO FilePath
defaultDataDir = getXdgDirectory XdgData "refl"

envFromConfig :: Config -> FilePath -> Env
envFromConfig cfg work = Env
  { envAgda = cfgAgda cfg
  , envAgdaDir = cfgAgdaDir cfg
  , envLean = cfgLean cfg
  , envLeanPath = cfgLeanPath cfg
  , envBend = cfgBend cfg
  , envBendPath = cfgBendPath cfg
  , envWorkRoot = work </> "sessions"
  , envVerbose = cfgVerbose cfg
  }
