module Main (main) where

import           Data.Aeson                    (decodeStrict)
import qualified Data.ByteString.Char8         as BC
import           Data.Maybe                    (mapMaybe)
import qualified Data.Text                     as T
import           Test.Hspec

import           Refl.Language.Agda            (applyMakeCase, replaceSpan)
import           Refl.Language.Agda.IOTCM
import           Refl.Language.Agda.Response
import           Refl.Language.Lean            (parseGoalText, theoremName)
import           Refl.Protocol.Types

main :: IO ()
main = hspec $ do
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
