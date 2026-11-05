-- | The Agda driver against a stand-in for @agda --interaction-json@: a shell
-- script that speaks the framing, so a slow answer or a death can be staged
-- exactly. What a real Agda says is pinned by the level checks; this is about
-- what the driver does when one stops answering.
module AgdaProcessSpec (spec) where

import           Control.Concurrent          (threadDelay)
import           Control.Exception           (bracket)
import           Data.Either                 (isLeft)
import qualified Data.Text                   as T
import qualified Data.Text.IO                as TIO
import           System.Directory
import           System.FilePath             ((</>))
import           System.IO                   (hClose, openTempFile)
import           Test.Hspec

import           Refl.Language
import           Refl.Language.Agda          (agda)
import           Refl.Language.Agda.IOTCM
import           Refl.Language.Agda.Process
import           Refl.Protocol.Types

withDir :: (FilePath -> IO a) -> IO a
withDir = bracket create removePathForcibly
 where
  create = do
    tmp <- getTemporaryDirectory
    (p, h) <- openTempFile tmp "refl-agda-test"
    hClose h
    removeFile p
    createDirectory p
    pure p

-- | Write the stand-in; its body runs once per command, with @$n@ the how-many'th
-- process this is and @$line@ the command.
standIn :: FilePath -> String -> IO FilePath
standIn dir body = do
  let exe = dir </> "agda"
  writeFile exe $ unlines
    [ "#!/bin/sh"
    , "d=" <> show dir
    , "n=$(($(cat \"$d/starts\" 2>/dev/null || echo 0) + 1))"
    , "echo \"$n\" > \"$d/starts\""
    , "printf 'JSON> '"
    , "while read -r line; do"
    , "  case \"$line\" in *Cmd_exit*) exit 0 ;; esac"
    , "  echo \"$n $line\" >> \"$d/commands\""
    , body
    , "  printf 'JSON> '"
    , "done"
    ]
  perms <- getPermissions exe
  setPermissions exe (setOwnerExecutable True perms)
  pure exe

-- | What each process was asked, in order, as (process, command name).
commands :: FilePath -> IO [(T.Text, T.Text)]
commands dir = map parse . T.lines <$> TIO.readFile (dir </> "commands")
 where
  parse l = case T.words l of
    n : ws | (_, c : _) <- break ("(Cmd_" `T.isPrefixOf`) ws -> (n, T.drop 1 c)
    _ -> ("?", l)

-- | The answer to a load: one hole at the start of the user's text.
loaded :: String
loaded = unlines
  [ "  printf '%s\\n' \\"
  , "    '{\"kind\":\"InteractionPoints\",\"interactionPoints\":[{\"id\":0,\"range\":[{\"start\":{\"pos\":1},\"end\":{\"pos\":2}}]}]}' \\"
  , "    '{\"kind\":\"DisplayInfo\",\"info\":{\"kind\":\"AllGoalsWarnings\",\"visibleGoals\":[{\"kind\":\"OfType\",\"constraintObj\":{\"id\":0,\"range\":[]},\"type\":\"T\"}],\"invisibleGoals\":[],\"warnings\":[],\"errors\":[]}}' \\"
  , "    '{\"kind\":\"Status\",\"status\":{\"checked\":false}}'"
  ]

-- | The answer to a goal command.
goal :: String
goal = "  printf '%s\\n' '{\"kind\":\"DisplayInfo\",\"info\":{\"kind\":\"GoalSpecific\",\"interactionPoint\":{\"id\":0,\"range\":[]},\"goalInfo\":{\"kind\":\"GoalType\",\"rewrite\":\"Normalised\",\"type\":\"T\",\"typeAux\":{\"kind\":\"GoalOnly\"},\"entries\":[],\"boundary\":[],\"outputForms\":[]}}}'"

env :: FilePath -> FilePath -> Env
env exe root = Env
  { envAgda = exe, envAgdaDir = Nothing, envLean = Nothing, envLeanPath = Nothing
  , envBend = Nothing, envBendPath = Nothing, envWorkRoot = root, envVerbose = False }

source :: LevelSources
source = LevelSources (LangId "agda") (WorldId "test") (LevelId "test") "Test" "" "" "?" "refl" [] False []

withSession :: Env -> (ProverSession -> IO a) -> IO a
withSession e = bracket open psClose
 where
  open = langStart agda e source >>= either (fail . T.unpack) pure

spec :: Spec
spec = describe "agda process" $ do
  it "never reads a timed-out command's late answer as the next command's" $ withDir $ \dir -> do
    exe <- standIn dir $ unlines
      [ "  case \"$(wc -l < \"$d/commands\")\" in"
      , "    *1) sleep 2; printf '%s\\n' '{\"kind\":\"late\"}' ;;"
      , "    *) printf '%s\\n' '{\"kind\":\"second\"}' ;;"
      , "  esac"
      ]
    Right p <- startAgda (const (pure ())) exe [] dir
    first <- sendCmd p 1 "f.agda" ALoad
    first `shouldSatisfy` isLeft
    threadDelay 2500000
    second <- sendCmd p 5 "f.agda" ALoad
    stopAgda p
    -- The process that owes an answer must be gone: an honest failure, not the
    -- abandoned command's answer passed off as this one's.
    second `shouldSatisfy` isLeft
    show second `shouldNotContain` "late"

  it "replaces an Agda that stops answering, and loads again before a hole command" $ withDir $ \dir -> do
    exe <- standIn dir $ unlines
      [ "  case \"$n$line\" in"
      , "    1*Cmd_goal*) exit 1 ;;"
      , "    *Cmd_goal*) " <> goal <> " ;;"
      , "    *) " <> loaded <> " ;;"
      , "  esac"
      ]
    withSession (env exe dir) $ \s -> do
      r <- psCheck s "?"
      map holeId (crHoles r) `shouldBe` [HoleId 0]
      let ask = psHole s "?" (TargetHole (HoleId 0)) (OpGoal NormNormalised)
      ask >>= \case
        OutError _ -> pure ()
        _ -> expectationFailure "the command that killed Agda should report a failure"
      ask >>= \case
        OutGoal g -> goalType g `shouldBe` "T"
        OutError e -> expectationFailure ("after a restart: " <> T.unpack e)
        _ -> expectationFailure "expected the goal"
      -- The new Agda knew no holes until it was given the file.
      commands dir >>= (`shouldBe`
        [("1", "Cmd_load"), ("1", "Cmd_goal_type_context"), ("2", "Cmd_load"), ("2", "Cmd_goal_type_context")])

  it "a check after a death runs in a new Agda" $ withDir $ \dir -> do
    exe <- standIn dir $ unlines
      [ "  case \"$n\" in"
      , "    1) exit 1 ;;"
      , "    *) " <> loaded <> " ;;"
      , "  esac"
      ]
    withSession (env exe dir) $ \s -> do
      first <- psCheck s "?"
      crVerdict first `shouldBe` Failed
      second <- psCheck s "?"
      crVerdict second `shouldNotBe` Failed
      map fst <$> commands dir >>= (`shouldBe` ["1", "2"])
