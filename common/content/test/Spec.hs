module Main (main) where

import qualified Data.Map             as M
import qualified Data.Text            as T
import qualified Data.ByteString.Lazy.Char8 as BL
import           Data.Aeson (encode)
import           Control.Exception (bracket)
import           System.Directory
import           System.FilePath ((</>))
import           System.IO (hClose, openTempFile)
import           Test.Hspec

import           Refl.Content
import           Refl.Content.Frontmatter (writeFileUtf8)
import qualified Refl.Protocol.Manifest as P
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
  describe "language-specific teaching" $ do
    it "isolates teaching, documents and independently authored examples" $ do
      let manifest = buildManifest [] fixture
          level = head (P.wLevels (head (P.mWorlds manifest)))
          leanPage = P.lLanguages level M.! LangId "lean"
          item = head (P.lUnlocks level)
      P.llIntroHtml leanPage `shouldSatisfy` T.isInfixOf "Lean only"
      P.llIntroHtml leanPage `shouldSatisfy` (not . T.isInfixOf "Agda only")
      M.lookup (LangId "lean") (P.iiDocHtml item) `shouldSatisfy` maybe False (T.isInfixOf "Lean document")
      P.llExampleCode leanPage `shouldSatisfy` T.isInfixOf "example-proof"
      BL.unpack (encode manifest) `shouldSatisfy` (not . T.isInfixOf "PRIVATE-EXERCISE-SOLUTION" . T.pack)
    it "never falls back to shared teaching or Agda documents" $ do
      let w = head (lgWorlds fixture)
          l = head (lwLevels w)
          missing = fixture { lgDocs = M.delete "lean/cmd-load" (lgDocs fixture)
            , lgWorlds = [w {lwLevels = [l {llTeaching = M.delete (LangId "lean") (llTeaching l)}]}] }
          public = head (P.wLevels (head (P.mWorlds (buildManifest [] missing))))
      M.member (LangId "lean") (P.lLanguages public) `shouldBe` False
      M.lookup (LangId "lean") (P.iiDocHtml (head (P.lUnlocks public))) `shouldBe` Nothing
      teachingProblems missing `shouldSatisfy` any (T.isInfixOf "missing teaching page")
    it "flags missing inventory translations and unsupported command references" $ do
      let change l = l {llTeaching = M.adjust (\t -> t {tIntro = "Use **Give** (C-c C-SPC)."}) (LangId "lean") (llTeaching l)}
          bad = fixture {lgDocs = M.delete "lean/cmd-load" (lgDocs fixture)
            , lgWorlds = map (\w -> w {lwLevels = map change (lwLevels w)}) (lgWorlds fixture)}
      teachingProblems bad `shouldSatisfy` any (T.isInfixOf "missing inventory translation")
      teachingProblems bad `shouldSatisfy` any (T.isInfixOf "unsupported command")
    it "rejects a playable source whose sibling teaching page is absent" $
      bracket temporary removeDirectoryRecursive $ \dir -> do
        writeFileUtf8 (dir </> "01-test.md") "---\nid: test\nindex: 1\ntitle: Test\n---\nShared text\n"
        writeFileUtf8 (dir </> "01-test.agda") sample
        result <- loadLevel (WorldId "test") M.empty (dir </> "01-test.md")
        result `shouldSatisfy` either (T.isInfixOf "missing teaching page") (const False)
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

temporary :: IO FilePath
temporary = do
  tmp <- getTemporaryDirectory
  (path, h) <- openTempFile tmp "refl-content-test"
  hClose h
  removeFile path
  createDirectory path
  pure path

fixture :: LoadedGame
fixture = LoadedGame (GameMeta "Test" ["w"]) "" [world]
  (M.fromList [("agda/cmd-load", "Agda document"), ("lean/cmd-load", "Lean document")]) "."
 where
  world = LoadedWorld (WorldMeta "w" "World" [] M.empty) "" [level] "."
  level = LoadedLevel (LevelMeta "l" 1 "Shared" [] (UnlockSpec ["load"] [] []) [] False [])
    "Shared Agda only" "" (M.fromList [(lang, source lang) | lang <- langs]) "01-test.md"
    (M.fromList [(lang, page lang) | lang <- langs])
  langs = [LangId "agda", LangId "lean"]
  source lang = srcs {lsLang = lang, lsSolution = "PRIVATE-EXERCISE-SOLUTION"}
  page lang = Teaching (TeachingMeta "Title" ["Goal"] [HintSpec "Clue" False, HintSpec "Next" True, HintSpec "Structure" True] "Example steps")
    (if lang == LangId "lean" then "Lean only" else "Agda only") "Conclusion"
    (srcs {lsLang = lang, lsPrefix = "example declaration\n", lsStatement = "example declaration\n", lsSolution = "example-proof"})
