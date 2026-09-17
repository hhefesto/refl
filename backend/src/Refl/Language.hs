-- | The language plugin interface. A language is a record of functions; the
-- engine never inspects prover-specific data.
--
-- Adding a language (Bend2, when it ships) means writing one module that
-- produces a 'Language' and registering it in "Refl.Language.Registry".
module Refl.Language
  ( Language (..)
  , ProverSession (..)
  , HoleOutcome (..)
  , Env (..)
  , LevelSources (..)
  , logMsg
  ) where

import           Data.Text           (Text)
import qualified Data.Text.IO        as TIO
import           System.IO           (hFlush, stderr)

import           Refl.Content.Level  (LevelSources (..))
import           Refl.Protocol.Types

-- | Runtime configuration shared by all plugins.
data Env = Env
  { envAgda        :: FilePath          -- ^ agda executable
  , envAgdaDir     :: Maybe FilePath    -- ^ AGDA_DIR (libraries/defaults), if not inherited
  , envLean        :: Maybe FilePath    -- ^ lean executable
  , envLeanPath    :: Maybe FilePath    -- ^ LEAN_PATH for the support library
  , envWorkRoot    :: FilePath          -- ^ where per-session directories are created
  , envVerbose     :: Bool
  }

logMsg :: Env -> Text -> IO ()
logMsg env t | envVerbose env = TIO.hPutStrLn stderr t >> hFlush stderr
             | otherwise      = pure ()

-- | What a hole operation produced.
data HoleOutcome
  = OutGoal Goal          -- ^ show this goal
  | OutText Text          -- ^ the user region was rewritten; re-check it
  | OutInfo Text Text     -- ^ title, body
  | OutError Text

-- | A live prover attached to one level for one player.
data ProverSession = ProverSession
  { psCheck :: Text -> IO CheckResult
    -- ^ full user region → load/check → result
  , psHole  :: Text -> Target -> HoleOp -> IO HoleOutcome
    -- ^ operate on a hole of the given user region (re-loaded if it changed)
  , psClose :: IO ()
  }

data Language = Language
  { langInfo        :: LangInfo
  , langCommands    :: [CommandId]
    -- ^ everything the prover can do at all; levels unlock a subset
  , langStaticRules :: LevelSources -> Text -> [Violation]
    -- ^ pure rejections before any prover runs
  , langStart       :: Env -> LevelSources -> IO (Either Text ProverSession)
  }
