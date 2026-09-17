module Main (main) where

import qualified Data.Map             as M
import qualified Data.Text            as T
import           Test.Hspec

import           Refl.Content.Level
import           Refl.Content.Regions
import           Refl.Content.Splice
import           Refl.Protocol.Types

sample :: T.Text
sample = T.unlines
  [ "-- @prelude"
  , "{-# OPTIONS --safe #-}"
  , "module Tutorial.Refl where"
  , "-- @statement"
  , "lemma : ∀ (n : ℕ) → n ≡ n"
  , "-- @template"
  , "lemma n = ?"
  , "-- @solution"
  , "lemma n = refl"
  ]

srcs :: LevelSources
srcs = LevelSources (LangId "agda") (WorldId "w") (LevelId "l") "Tutorial.Refl"
  "prelude\nstatement\n" "statement\n" "t\n" "s\n" ["+-comm"] False []

main :: IO ()
main = hspec $ do
  describe "parseRegions" $ do
    it "splits the four regions" $ do
      let Right r = parseRegions "--" sample
      rPrelude r `shouldBe` "{-# OPTIONS --safe #-}\nmodule Tutorial.Refl where\n"
      rStatement r `shouldBe` "lemma : ∀ (n : ℕ) → n ≡ n\n"
      rTemplate r `shouldBe` "lemma n = ?\n"
      rSolution r `shouldBe` "lemma n = refl\n"
      moduleNameOf (rPrelude r) `shouldBe` Just "Tutorial.Refl"
    it "rejects a missing marker" $
      parseRegions "--" "-- @prelude\nx\n-- @statement\n" `shouldSatisfy` isLeft
    it "rejects a duplicated marker" $
      parseRegions "--" (sample <> "-- @solution\n") `shouldSatisfy` isLeft
  describe "splice" $ do
    it "concatenates prefix, user, suffix" $
      splice srcs "" "lemma n = refl" `shouldBe` "prelude\nstatement\nlemma n = refl\n"
    it "userOffset counts code points" $
      userOffset srcs `shouldBe` T.length "prelude\nstatement\n"
  describe "agda rules" $ do
    it "accept a plain proof" $ agdaRules srcs "lemma n = refl\n" `shouldBe` []
    it "reject postulate" $ map vRule (agdaRules srcs "postulate x : ℕ\n") `shouldBe` ["unsafe"]
    it "reject OPTIONS pragmas" $ map vRule (agdaRules srcs "{-# OPTIONS --no-safe #-}\n") `shouldBe` ["pragma"]
    it "reject imports unless allowed" $ map vRule (agdaRules srcs "open import Data.Nat\n") `shouldBe` ["import"]
    it "ignore comments" $ agdaRules srcs "-- postulate\n{- postulate -}\nlemma n = refl\n" `shouldBe` []
  describe "lean rules" $ do
    it "accept indented tactics" $ leanRules srcs "  rfl\n" `shouldBe` []
    it "reject a top-level line" $ map vRule (leanRules srcs "theorem evil : 1 = 2 := sorry\n") `shouldSatisfy` ("indent" `elem`)
    it "reject axiom" $ map vRule (leanRules srcs "  exact (axiom_x)\n") `shouldBe` []
    it "reject set_option" $ map vRule (leanRules srcs "  set_option maxRecDepth 10 in rfl\n") `shouldBe` ["unsafe"]
  describe "bend rules" $ do
    it "accept a proof" $ bendRules srcs "def two_plus_two():\n  {==}\n" `shouldBe` []
    it "reject a main" $ map vRule (bendRules srcs "def main() -> IO(Unit):\n  IO.print(\"x\")\n") `shouldBe` ["main"]
    it "reject a law named main" $ map vRule (bendRules srcs "law main:\n  U32\n") `shouldBe` ["main"]
    it "reject imports" $ map vRule (bendRules srcs "import ./x.bend as X\n") `shouldBe` ["import"]
    it "reject @unsafe" $ map vRule (bendRules srcs "@unsafe\ndef loop(x: Nat) -> Nat:\n  loop(x)\n") `shouldBe` ["unsafe"]
    it "ignore comments" $ bendRules srcs "# import main @unsafe\ndef f():\n  {==}\n" `shouldBe` []
  describe "forbidden identifiers" $ do
    it "finds a forbidden lemma" $
      map vRule (forbiddenIdentifiers "--" ["+-comm"] "lemma n = +-comm n zero\n") `shouldBe` ["forbidden"]
    it "does not match inside comments" $
      forbiddenIdentifiers "--" ["+-comm"] "-- +-comm\nlemma n = refl\n" `shouldBe` []
    it "does not match a longer token" $
      forbiddenIdentifiers "--" ["+-comm"] "lemma n = +-comm′ n\n" `shouldBe` []
  describe "tokens" $
    it "keeps unicode operators together" $
      tokens "x ≤-refl (+-comm n)" `shouldBe` ["x", "≤-refl", "+-comm", "n"]
  where
    isLeft (Left _) = True
    isLeft _        = False
    _unused = M.empty :: M.Map Int Int
