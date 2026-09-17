-- | refl-check-levels GAMES [--lang L] [--emit-world-modules DIR] [--world W]
module Main (main) where

import           Control.Monad        (forM_, unless, when)
import           Data.Maybe           (fromMaybe)
import qualified Data.Text            as T
import qualified Data.Text.IO         as TIO
import           Options.Applicative
import           System.Directory     (createDirectoryIfMissing,
                                       getTemporaryDirectory)
import           System.Environment   (lookupEnv)
import           System.Exit          (exitFailure)
import           System.FilePath      ((</>))
import           System.IO            (stderr)

import           Refl.Check
import           Refl.Content         (loadGame, lgWorlds, lwMeta, wmId)
import           Refl.Language        (Env (..))
import           Refl.Protocol.Types  (LangId (..))

data Opts = Opts
  { optGames   :: FilePath
  , optLang    :: Maybe String
  , optWorld   :: Maybe String
  , optEmit    :: Maybe FilePath
  , optAgda    :: Maybe FilePath
  , optAgdaDir :: Maybe FilePath
  , optLean    :: Maybe FilePath
  , optLeanPath :: Maybe FilePath
  , optVerbose :: Bool
  }

main :: IO ()
main = do
  o <- execParser $ info (parser <**> helper) (fullDesc <> progDesc "Type-check every level's solution and template")
  eAgda <- lookupEnv "REFL_AGDA"
  eAgdaDir <- lookupEnv "AGDA_DIR"
  eLean <- lookupEnv "REFL_LEAN"
  eLeanPath <- lookupEnv "REFL_LEAN_PATH"
  tmp <- getTemporaryDirectory
  let work = tmp </> "refl-check"
  createDirectoryIfMissing True work
  let env = Env
        { envAgda = fromMaybe (fromMaybe "agda" eAgda) (optAgda o)
        , envAgdaDir = optAgdaDir o <|> eAgdaDir
        , envLean = optLean o <|> eLean
        , envLeanPath = optLeanPath o <|> eLeanPath
        , envWorkRoot = work
        , envVerbose = optVerbose o
        }
  r <- loadGame (optGames o)
  case r of
    Left err -> TIO.hPutStrLn stderr err >> exitFailure
    Right g0 -> do
      let g = case optWorld o of
            Nothing -> g0
            Just w -> g0 { lgWorlds = filter ((== T.pack w) . wmId . lwMeta) (lgWorlds g0) }
      forM_ (optEmit o) $ \dir -> do
        paths <- emitWorldModules g0 dir
        forM_ paths (putStrLn . ("wrote " ++))
      when (optEmit o == Nothing || optLang o /= Nothing || True) $ do
        outcomes <- checkGame env (LangId . T.pack <$> optLang o) g
        forM_ outcomes $ \oc -> do
          TIO.putStrLn ((if oOk oc then "ok   " else "FAIL ") <> oWorld oc <> "/" <> oLevel oc <> " [" <> oLang oc <> "]")
          forM_ (oNotes oc) (TIO.putStrLn . ("       " <>))
        let bad = length (filter (not . oOk) outcomes)
        putStrLn (show (length outcomes) ++ " checks, " ++ show bad ++ " failed")
        unless (bad == 0) exitFailure
 where
  parser = Opts
    <$> strArgument (metavar "GAMES")
    <*> optional (strOption (long "lang" <> metavar "LANG"))
    <*> optional (strOption (long "world" <> metavar "WORLD" <> help "Only this world id"))
    <*> optional (strOption (long "emit-world-modules" <> metavar "DIR" <> help "Write Refl/World/*.agda under DIR"))
    <*> optional (strOption (long "agda"))
    <*> optional (strOption (long "agda-dir"))
    <*> optional (strOption (long "lean"))
    <*> optional (strOption (long "lean-path"))
    <*> switch (long "verbose" <> short 'v')
