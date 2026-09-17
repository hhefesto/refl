module Main (main) where

import           Data.Aeson            (FromJSON, ToJSON, Value (Null), decode, encode)
import qualified Data.Map              as M
import qualified Data.Text             as T
import           Test.Hspec
import           Test.QuickCheck

import           Refl.Protocol

main :: IO ()
main = hspec $ do
  describe "aeson round trips" $ do
    it "ClientMsg" $ property $ \m -> roundTrip (m :: ClientMsg)
    it "ServerMsg" $ property $ \m -> roundTrip (m :: ServerMsg)
    it "CheckResult" $ property $ \m -> roundTrip (m :: CheckResult)
  describe "Route" $ do
    it "decode . encode = Just" $ property $ \r -> decodeRoute (encodeRoute r) == Just (r :: Route)
    it "decodes the bare map" $ decodeRoute "#/" `shouldBe` Just RWorldMap
    it "decodes without a hash" $ decodeRoute "/inventory" `shouldBe` Just RInventory

roundTrip :: (Eq a, ToJSON a, FromJSON a) => a -> Bool
roundTrip x = decode (encode x) == Just x

-- Arbitrary instances ---------------------------------------------------------

slug :: Gen T.Text
slug = T.pack <$> listOf1 (elements (['a' .. 'z'] ++ ['0' .. '9'] ++ "-"))

txt :: Gen T.Text
txt = T.pack <$> arbitrary

instance Arbitrary LangId where arbitrary = LangId <$> slug
instance Arbitrary WorldId where arbitrary = WorldId <$> slug
instance Arbitrary LevelId where arbitrary = LevelId <$> slug
instance Arbitrary HoleId where arbitrary = HoleId <$> arbitrary
instance Arbitrary Span where arbitrary = Span <$> arbitrary <*> arbitrary
instance Arbitrary Target where
  arbitrary = oneof [TargetHole <$> arbitrary, TargetPos <$> arbitrary]
instance Arbitrary Hole where arbitrary = Hole <$> arbitrary <*> arbitrary <*> oneof [pure Nothing, Just <$> txt]
instance Arbitrary ContextEntry where arbitrary = ContextEntry <$> txt <*> txt <*> arbitrary
instance Arbitrary Goal where arbitrary = Goal <$> arbitrary <*> txt <*> arbitrary <*> pure (toJSONUnit ())
instance Arbitrary Severity where arbitrary = elements [minBound .. maxBound]
instance Arbitrary Diagnostic where arbitrary = Diagnostic <$> arbitrary <*> arbitrary <*> txt
instance Arbitrary HighlightSpan where arbitrary = HighlightSpan <$> arbitrary <*> listOf txt
instance Arbitrary Violation where arbitrary = Violation <$> txt <*> arbitrary <*> txt
instance Arbitrary Verdict where
  arbitrary = oneof [pure Solved, Unsolved <$> arbitrary, Rejected <$> arbitrary, pure Failed]
instance Arbitrary CheckResult where
  arbitrary = CheckResult <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary <*> txt <*> pure (toJSONUnit ())
instance Arbitrary Normalisation where arbitrary = elements [minBound .. maxBound]
instance Arbitrary HoleOp where
  arbitrary = oneof
    [ OpGoal <$> arbitrary, OpGive <$> txt, OpRefine <$> txt, pure OpIntro
    , OpCase <$> txt, pure OpAuto, OpInfer <$> arbitrary <*> txt
    , OpNormalise <$> txt, OpHelperType <$> txt ]
instance Arbitrary CommandId where arbitrary = elements [minBound .. maxBound]
instance Arbitrary LangInfo where arbitrary = LangInfo <$> arbitrary <*> txt <*> slug <*> slug <*> arbitrary
instance Arbitrary Progress where
  arbitrary = Progress <$> (M.fromList <$> listOf ((,) <$> arbitrary <*> listOf txt))
                       <*> (M.fromList <$> listOf ((,) <$> txt <*> (M.fromList <$> listOf ((,) <$> arbitrary <*> txt))))
instance Arbitrary ClientMsg where
  arbitrary = oneof
    [ OpenSession <$> arbitrary <*> arbitrary <*> arbitrary
    , Check <$> txt, HoleCmd <$> arbitrary <*> arbitrary, SaveDraft <$> txt
    , pure GetProgress, pure Ping ]
instance Arbitrary ServerMsg where
  arbitrary = oneof
    [ SessionOpened <$> arbitrary <*> listOf arbitrary <*> txt
    , SessionUnavailable <$> txt, Checked <$> arbitrary, GoalShown <$> arbitrary
    , TextReplaced <$> txt <*> arbitrary, Info <$> txt <*> txt
    , ProgressState <$> arbitrary, pure Busy, ServerError <$> txt, pure Pong ]
instance Arbitrary Route where
  arbitrary = oneof
    [ pure RWorldMap, RWorld <$> arbitrary
    , RLevel <$> arbitrary <*> (getNonNegative <$> arbitrary) <*> arbitrary
    , pure RInventory ]

toJSONUnit :: () -> Value
toJSONUnit () = Null
