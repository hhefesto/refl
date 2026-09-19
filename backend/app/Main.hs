module Main (main) where

import           Control.Monad                        (unless)
import           Data.Maybe                           (fromMaybe)
import           Data.String                          (fromString)
import qualified Data.Text.IO                         as TIO
import qualified Network.Wai.Handler.Warp             as Warp
import           Network.Wai.Middleware.RequestLogger (logStdout)
import           Options.Applicative
import           System.Directory                     (createDirectoryIfMissing)
import           System.Environment                   (lookupEnv)
import           System.Exit                          (exitFailure)
import           System.FilePath                      ((</>))
import           System.IO

import           Refl.Config
import           Refl.Content                         (loadGame)
import           Refl.Server
import           Refl.Server.Progress

opts :: Maybe String -> Maybe String -> Maybe String -> Maybe String -> Maybe String -> Maybe String -> Maybe String -> Parser Config
opts eGames eAgda eAgdaDir eLean eLeanPath eBend eBendPath = Config
  <$> optional (strOption (long "www" <> metavar "DIR" <> help "Static site directory (index.html, all.js)"))
  <*> strOption (long "games" <> metavar "DIR" <> value (fromMaybe "games/refl" eGames) <> showDefault <> help "Game content directory")
  <*> option auto (long "port" <> value 8090 <> showDefault)
  <*> strOption (long "host" <> value "127.0.0.1" <> showDefault)
  <*> switch (long "dev" <> help "Permissive CORS for the jsaddle-warp dev client")
  <*> optional (strOption (long "data-dir" <> metavar "DIR" <> help "Where progress.json lives (default: $XDG_DATA_HOME/refl)"))
  <*> optional (strOption (long "work-dir" <> metavar "DIR" <> help "Per-session prover directories (default: <data-dir>/work)"))
  <*> strOption (long "agda" <> metavar "PATH" <> value (fromMaybe "agda" eAgda) <> showDefault)
  <*> optional (strOption (long "agda-dir" <> metavar "DIR" <> help "AGDA_DIR with libraries/defaults") <|> pure' eAgdaDir)
  <*> optional (strOption (long "lean" <> metavar "PATH") <|> pure' eLean)
  <*> optional (strOption (long "lean-path" <> metavar "DIR" <> help "LEAN_PATH of the support library") <|> pure' eLeanPath)
  <*> optional (strOption (long "bend" <> metavar "PATH" <> help "bend executable (Bend 2)") <|> pure' eBend)
  <*> optional (strOption (long "bend-path" <> metavar "DIR" <> help "Directory of .bend support files") <|> pure' eBendPath)
  <*> switch (long "verbose" <> short 'v')
  <*> optional (strOption (long "origin" <> help "Exact allowed browser origin (default: http://host:port)"))
  <*> option positive (long "max-sessions" <> value 4 <> showDefault)
  <*> option positive (long "message-bytes" <> value 65536 <> showDefault)
  <*> option positive (long "command-seconds" <> value 120 <> showDefault)
  <*> option positive (long "idle-seconds" <> value 300 <> showDefault)
 where
  pure' = maybe empty pure
  positive = eitherReader $ \s -> case reads s of
    [(n, "")] | n > 0 && n <= 1000000 -> Right n
    _ -> Left "expected an integer in 1..1000000"

main :: IO ()
main = do
  hSetBuffering stdout LineBuffering
  hSetBuffering stderr LineBuffering
  eGames <- lookupEnv "REFL_GAMES"
  eAgda <- lookupEnv "REFL_AGDA"
  eAgdaDir <- lookupEnv "AGDA_DIR"
  eLean <- lookupEnv "REFL_LEAN"
  eLeanPath <- lookupEnv "REFL_LEAN_PATH"
  eBend <- lookupEnv "REFL_BEND"
  eBendPath <- lookupEnv "REFL_BEND_PATH"
  cfg <- execParser (info (opts eGames eAgda eAgdaDir eLean eLeanPath eBend eBendPath <**> helper)
           (fullDesc <> progDesc "The Refl Game server"))
  dataDir <- maybe defaultDataDir pure (cfgDataDir cfg)
  let workDir = fromMaybe (dataDir </> "work") (cfgWorkDir cfg)
  createDirectoryIfMissing True (workDir </> "sessions")
  game <- loadGame (cfgGames cfg)
  case game of
    Left err -> TIO.hPutStrLn stderr ("content error: " <> err) >> exitFailure
    Right g -> do
      store <- openStore (dataDir </> "progress.json")
      let env = envFromConfig cfg workDir
      se <- newServerEnv cfg env g store
      unless (cfgWww cfg /= Nothing) $
        putStrLn "no --www given: serving the API only"
      putStrLn ("The Refl Game at http://" ++ cfgHost cfg ++ ":" ++ show (cfgPort cfg))
      let settings = Warp.setPort (cfgPort cfg) $ Warp.setHost (fromString (cfgHost cfg)) Warp.defaultSettings
      Warp.runSettings settings (if cfgVerbose cfg then logStdout (app se) else app se)
