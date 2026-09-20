module Main (main) where

import           Data.Aeson                    (decodeStrict, Value (Null), object, (.=))
import qualified Data.ByteString.Char8         as BC
import           Data.Maybe                    (mapMaybe)
import qualified Data.Text                     as T
import qualified AnalyticsSpec
import           Test.Hspec

import           Refl.Language.Agda            (applyMakeCase, replaceSpan, resultFrom, tidyMessage)
import           Refl.Content.Level           (LevelSources (..))
import           Refl.Language.Agda.IOTCM
import           Refl.Language.Agda.Response
import           Refl.Language.Lean            (parseGoalText, theoremName)
import           Refl.Language.Bend2           (BendReport (..), holesIn, parseBendReport, reportResult)
import           System.Exit                   (ExitCode (..))
import           Refl.Protocol.Types
import           Refl.Check (exampleProblems)
import           Refl.Server.Identity

main :: IO ()
main = hspec $ do
  AnalyticsSpec.spec
  describe "anonymous identity boundary" $ do
    let secure = cookiePolicy "https://refl.example"
    it "rejects path traversal, duplicate cookies and short tokens" $ do
      identity secure [("Cookie", "__Host-refl=../../progress")] `shouldBe` Nothing
      identity secure [("Cookie", "__Host-refl=abc")] `shouldBe` Nothing
      token <- newIdentity
      identity secure [("Cookie", "__Host-refl=" <> token)] `shouldBe` Just token
      identity secure [("Cookie", "__Host-refl=" <> token <> "; __Host-refl=" <> token)] `shouldBe` Nothing
    it "uses a Secure host-only cookie on https and loopback origins only" $ do
      cookiePolicy "https://refl.example" `shouldBe` CookiePolicy "__Host-refl" True
      cookiePolicy "http://127.0.0.1:8090" `shouldBe` CookiePolicy "__Host-refl" True
      cookiePolicy "http://localhost:8090" `shouldBe` CookiePolicy "__Host-refl" True
      cookiePolicy "http://[::1]:3007" `shouldBe` CookiePolicy "__Host-refl" True
      cookiePolicy "http://62.238.6.4:3007" `shouldBe` CookiePolicy "refl" False
      cookiePolicy "http://refl.example" `shouldBe` CookiePolicy "refl" False
      token <- newIdentity
      let public = cookiePolicy "http://62.238.6.4:3007"
      identityCookie public token `shouldBe` ("refl=" <> token <> "; Path=/; HttpOnly; SameSite=Strict; Max-Age=31536000")
      identityCookie secure token `shouldBe` ("__Host-refl=" <> token <> "; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=31536000")
      identity public [("Cookie", "refl=" <> token)] `shouldBe` Just token
      identity public [("Cookie", "__Host-refl=" <> token)] `shouldBe` Nothing
    it "rejects missing, duplicate and foreign origins" $ do
      validOrigin "https://refl.example" [] `shouldBe` False
      validOrigin "https://refl.example" [("Origin", "https://refl.example.attacker")] `shouldBe` False
      validOrigin "https://refl.example" [("Origin", "https://refl.example"), ("Origin", "https://refl.example")] `shouldBe` False
      validOrigin "https://refl.example" [("Origin", "https://refl.example")] `shouldBe` True
  describe "IOTCM" $ do
    it "renders load" $
      renderIOTCM "/x/A.agda" ALoad `shouldBe` "IOTCM \"/x/A.agda\" NonInteractive Direct (Cmd_load \"/x/A.agda\" [])"
    it "renders give with escaping" $
      renderIOTCM "/x/A.agda" (AGive 0 "λ x → \"q\"")
        `shouldBe` "IOTCM \"/x/A.agda\" NonInteractive Direct (Cmd_give WithoutForce 0 noRange \"\\955 x \\8594 \\\"q\\\"\")"
    it "renders autoOne" $
      renderIOTCM "f" (AAutoOne 3) `shouldBe` "IOTCM \"f\" NonInteractive Direct (Cmd_autoOne AsIs 3 noRange \"\")"
  describe "responses" $ do
    let rs = mapMaybe (fmap decodeResponse . decodeStrict . BC.pack) (lines transcript)
    it "decodes the recorded transcript" $ length rs `shouldBe` 7
    it "finds interaction points" $
      [ x | RInteractionPoints x <- rs ] `shouldBe` [[(0, Just (206, 207)), (1, Just (251, 257))]]
    it "finds goals and no errors" $
      case [ d | RDisplay d@(DAllGoals {}) <- rs ] of
        [DAllGoals vis invis ws es] -> do
          map geId vis `shouldBe` [0, 1]
          invis `shouldBe` []
          ws `shouldBe` []
          es `shouldBe` []
        other -> expectationFailure (show other)
    it "decodes give actions (recorded from Agda 2.8.0)" $
      decodeResponse (maybe (error "json") id (decodeStrict "{\"giveResult\":{\"str\":\"refl\"},\"interactionPoint\":{\"id\":0,\"range\":[{\"end\":{\"col\":17,\"line\":7,\"pos\":146},\"start\":{\"col\":16,\"line\":7,\"pos\":145}}]},\"kind\":\"GiveAction\"}"))
        `shouldBe` RGiveAction 0 (GiveString "refl")
    it "decodes make case" $
      decodeResponse (maybe (error "json") id (decodeStrict "{\"kind\":\"MakeCase\",\"interactionPoint\":0,\"variant\":\"Function\",\"clauses\":[\"f zero = ?\",\"f (suc n) = ?\"]}"))
        `shouldBe` RMakeCase "Function" ["f zero = ?", "f (suc n) = ?"]
  describe "text edits" $ do
    it "replaceSpan" $ replaceSpan (Span 10 11) "refl" "lemma x = ?\n" `shouldBe` "lemma x = refl\n"
    it "applyMakeCase keeps indentation and joins clauses" $
      applyMakeCase "foo : ℕ\nfoo = zero\n  where\n  bar x = ?\n" (Span 32 33) ["bar zero = ?", "bar (suc n) = ?"]
        `shouldBe` "foo : ℕ\nfoo = zero\n  where\n  bar zero = ?\n  bar (suc n) = ?\n"
  describe "completion evidence" $ do
    let src = LevelSources (LangId "agda") (WorldId "test") (LevelId "test") "Test" "" "" "?" "refl" [] False []
        verdict = crVerdict . resultFrom src "?"
        complete = [RInteractionPoints [], RDisplay (DAllGoals [] [] [] []), RStatus True]
    it "requires all three parts of a complete successful load" $ do
      verdict complete `shouldBe` Solved
      mapM_ (\rs -> verdict rs `shouldBe` Failed)
        [[], tail complete, take 2 complete, [RStatus True], complete ++ [ROther "bad JSON"]]
    it "does not invent empty arrays for malformed goals" $ do
      let malformed = decodeResponse (object ["kind" .= ("DisplayInfo" :: T.Text), "info" .= object ["kind" .= ("AllGoalsWarnings" :: T.Text)]])
      verdict [RInteractionPoints [], malformed, RStatus True] `shouldBe` Failed
      verdict [decodeResponse Null] `shouldBe` Failed
    it "counts invisible metas and orphan interaction points" $ do
      verdict [RInteractionPoints [], RDisplay (DAllGoals [] [GoalEntry 2 "Set"] [] []), RStatus False] `shouldBe` Unsolved 1
      verdict [RInteractionPoints [(0, Nothing)], RDisplay (DAllGoals [] [] [] []), RStatus False] `shouldBe` Unsolved 1
    it "does not solve a load with errors or unsolved-meta warnings" $ do
      verdict (complete ++ [RDisplay (DError "type error" [])]) `shouldBe` Failed
      verdict [RInteractionPoints [], RDisplay (DAllGoals [] [] [Msg "Unsolved metas" Nothing] []), RStatus False] `shouldBe` Unsolved 1
    it "reports a type error once, without blaming the protocol" $ do
      let rs = [RStatus False, RJumpToError 3, RDisplay (DError "type error" [])]
      verdict rs `shouldBe` Failed
      map diagMessage (crDiagnostics (resultFrom src "?" rs)) `shouldBe` ["type error"]
  describe "tidyMessage" $ do
    let file = "/tmp/s/agda-1/Tutorial/Refl.agda"
    it "rewrites whole-file positions to user-region lines" $
      tidyMessage file 6 (T.pack file <> ":7.16-20: error: [UnequalTerms]\nat " <> T.pack file <> ":7.16-8.1")
        `shouldBe` "line 1.16-20: error: [UnequalTerms]\nat line 1.16-8.1"
    it "names the prelude when the position is above the user region" $
      tidyMessage file 6 (T.pack file <> ":3.1-2: x") `shouldBe` "the fixed prelude, line 3.1-2: x"
    it "leaves other text alone" $
      tidyMessage file 6 "no path here" `shouldBe` "no path here"
  describe "bend report" $ do
    let src = LevelSources (LangId "bend2") (WorldId "t") (LevelId "t") "Level" "import Base\nimport ./Refl.bend as Refl\nlaw t:\n  {1n == 1n : Nat}\n" "law t:\n  {1n == 1n : Nat}\n" "def t():\n  ?goal\n" "def t():\n  {==}\n" [] False []
        holeErr = "Error:\n- expected : {Refl.add(0n, x) == x : Nat}\n- observed : ?goal\nContext:\n- x : Nat\nLocation: zero_add\n 8 | def zero_add(x):\n 9>|   ?goal\n10 | \n"
    it "recognises success" $ parseBendReport ExitSuccess "All terms check.\n" "" `shouldBe` BendOk "All terms check."
    it "counts TODOs" $ parseBendReport (ExitFailure 1) "" "Error: 2 TODOs found.\nThe code is incomplete, and not a valid proof yet.\n" `shouldBe` BendTodos 2
    it "reads a loud hole with its context and line" $
      parseBendReport (ExitFailure 1) "" holeErr `shouldBe` BendHole "?goal" "{Refl.add(0n, x) == x : Nat}" [ContextEntry "x" "Nat" True] (Just 9)
    it "reads a mismatch" $
      parseBendReport (ExitFailure 1) "" "Error:\n- expected : 4n\n- observed : 5n\nLocation: two_plus_two\n6 | def two_plus_two():\n7>|   {==}\n8 | \n"
        `shouldBe` BendMismatch "4n" "5n" [] (Just 7)
    it "keeps anything else" $ parseBendReport (ExitFailure 1) "" "bend: boom\n" `shouldBe` BendOther "bend: boom"
    it "finds holes" $ holesIn "def t():\n  ?goal\n  f(?TODO, x)\n" `shouldBe` [("?goal", Span 11 16), ("?TODO", Span 21 26)]
    it "turns a loud hole into an Unsolved result with a typed hole" $ do
      let r = reportResult src "def t():\n  ?goal\n" (parseBendReport (ExitFailure 1) "" holeErr)
      crVerdict r `shouldBe` Unsolved 1
      map holeType (crHoles r) `shouldBe` [Just "{Refl.add(0n, x) == x : Nat}"]
    it "maps a mismatch line to the user region" $ do
      -- prefix has 4 lines; file line 7 is user line 3 (0-based 2) = "  {==}"
      let r = reportResult src "def t():\n  x = 1n\n  {==}\n" (BendMismatch "4n" "5n" [] (Just 7))
      crVerdict r `shouldBe` Failed
      map diagSpan (crDiagnostics r) `shouldBe` [Just (Span 18 24)]
    it "is Solved on success" $ crVerdict (reportResult src "def t():\n  {==}\n" (BendOk "All terms check.")) `shouldBe` Solved
  describe "lean helpers" $ do
    it "theoremName" $ theoremName "theorem add_zero (n : MyNat) : n + 0 = n := by\n" `shouldBe` Just "add_zero"
    it "parseGoalText" $
      parseGoalText "n : MyNat\nh : n = 0\n⊢ n + 0 = n" `shouldBe`
        ([ContextEntry "n" "MyNat" True, ContextEntry "h" "n = 0" True], "n + 0 = n")
  where
    transcript = unlines
      [ "{\"kind\":\"Status\",\"status\":{\"checked\":false,\"showImplicitArguments\":false,\"showIrrelevantArguments\":false}}"
      , "{\"kind\":\"ClearRunningInfo\"}"
      , "{\"kind\":\"ClearHighlighting\",\"tokenBased\":\"NotOnlyTokenBased\"}"
      , "{\"debugLevel\":1,\"kind\":\"RunningInfo\",\"message\":\"Checking Tutorial.Refl (/tmp/x/Tutorial/Refl.agda).\\n\"}"
      , "{\"kind\":\"InteractionPoints\",\"interactionPoints\":[{\"id\":0,\"range\":[{\"start\":{\"pos\":206,\"line\":16,\"col\":11},\"end\":{\"pos\":207,\"line\":16,\"col\":12}}]},{\"id\":1,\"range\":[{\"start\":{\"pos\":251,\"line\":19,\"col\":12},\"end\":{\"pos\":257,\"line\":19,\"col\":18}}]}]}"
      , "{\"info\":{\"errors\":[],\"invisibleGoals\":[],\"kind\":\"AllGoalsWarnings\",\"visibleGoals\":[{\"constraintObj\":{\"id\":0,\"range\":[]},\"kind\":\"OfType\",\"type\":\"x + zero ≡ x\"},{\"constraintObj\":{\"id\":1,\"range\":[]},\"kind\":\"OfType\",\"type\":\"suc x ≡ suc x\"}],\"warnings\":[]},\"kind\":\"DisplayInfo\"}"
      , "{\"kind\":\"Status\",\"status\":{\"checked\":true,\"showImplicitArguments\":false,\"showIrrelevantArguments\":false}}"
      ]
    _unusedT = T.empty
