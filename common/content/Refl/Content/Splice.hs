-- | Splicing the player's text into a level's fixed prefix/suffix, and the
-- pure static rules that reject tampering before a prover is consulted.
module Refl.Content.Splice
  ( splice
  , userOffset
  , agdaRules
  , leanRules
  , bendRules
  , forbiddenIdentifiers
  , stripComments
  , tokens
  ) where

import           Data.Char           (isSpace)
import           Data.Text           (Text)
import qualified Data.Text           as T

import           Refl.Content.Level
import           Refl.Protocol.Types

-- | @prefix <> user <> suffix@. The user region must end in a newline so the
-- suffix starts on its own line.
splice :: LevelSources -> Text -> Text -> Text
splice src suffix user =
  lsPrefix src <> ensureNl user <> suffix
 where
  ensureNl t | T.null t || T.last t == '\n' = t
             | otherwise = t <> "\n"

-- | Code-point offset of the user region inside the spliced file.
userOffset :: LevelSources -> Int
userOffset = T.length . lsPrefix

-- | Agda: things @--safe@ would refuse anyway, rejected early with a clear
-- message, plus imports unless the level allows them. Spans are located by
-- the first occurrence.
agdaRules :: LevelSources -> Text -> [Violation]
agdaRules src user =
  [ Violation "pragma" (spanOf w) ("`" <> w <> "` is not allowed in a level; the fixed prelude decides the options.")
  | w <- ["{-# OPTIONS", "{-# TERMINATING", "{-# NON_TERMINATING", "{-# NO_POSITIVITY_CHECK", "{-# NO_UNIVERSE_CHECK", "{-# BUILTIN", "{-# COMPILE", "{-# REWRITE"]
  , w `T.isInfixOf` code ]
  ++
  [ Violation "unsafe" (spanOf w) ("`" <> w <> "` is not allowed: every level is checked with --safe.")
  | w <- ["postulate", "primitive", "unquote", "trustMe", "primTrustMe"]
  , w `elem` toks ]
  ++
  [ Violation "import" (spanOf "import") "Imports are not allowed in this level; use what the inventory gives you."
  | not (lsAllowImports src), "import" `elem` toks ]
  ++
  [ Violation "literate" (spanOf "\\end{code}") "Do not close the code block."
  | "\\end{code}" `T.isInfixOf` code ]
 where
  code = stripComments "--" user
  toks = tokens code
  spanOf w = case T.breakOn w user of
    (before, rest) | T.null rest -> Nothing
                   | otherwise -> Just (Span (T.length before) (T.length before + T.length w))

-- | Lean: the user region lives inside a @by@ block, so every non-blank line
-- must stay indented, and no escape hatch may appear.
leanRules :: LevelSources -> Text -> [Violation]
leanRules _ user =
  [ Violation "indent" (Just (Span off (off + T.length l)))
      "Every line must be indented by at least two spaces: the proof stays inside the `by` block."
  | (off, l) <- lineOffsets user
  , not (T.all isSpace l), not ("  " `T.isPrefixOf` l) ]
  ++
  [ Violation "unsafe" (spanOf w) ("`" <> w <> "` is not allowed in a level.")
  | w <- ["axiom", "unsafe", "implemented_by", "extern", "set_option", "native_decide", "import", "opaque", "partial"]
  , w `elem` tokens code ]
 where
  code = stripComments "--" user
  spanOf w = case T.breakOn w user of
    (before, rest) | T.null rest -> Nothing
                   | otherwise -> Just (Span (T.length before) (T.length before + T.length w))

lineOffsets :: Text -> [(Int, Text)]
lineOffsets t = go 0 (T.splitOn "\n" t)
 where
  go _ [] = []
  go off (l : ls) = (off, l) : go (off + T.length l + 1) ls

-- | Bend 2: the checker runs @main@ after checking, so no @main@ may be
-- defined; @import@ (which can pull in foreign C/JS bodies or hub packages)
-- and @\@unsafe@ (which switches off termination checking) are out.
bendRules :: LevelSources -> Text -> [Violation]
bendRules _ user =
  [ Violation "main" (spanOf "main")
      "A level may not define `main`: Bend runs it, and this is a proof, not a program."
  | defsMain ]
  ++
  [ Violation "import" (spanOf "import")
      "Imports are not allowed in a level; the fixed prelude imports Base and Refl."
  | "import" `elem` toks ]
  ++
  [ Violation "unsafe" (spanOf "@unsafe")
      "`@unsafe` is not allowed in a level: every proof must terminate."
  | "@unsafe" `elem` toks ]
 where
  toks = tokens (stripComments "#" user)
  defsMain = or [ isMain n | (k, n) <- zip toks (drop 1 toks), k `elem` ["def", "law"] ]
  isMain n = n == "main" || n == "main:"
  spanOf w = case T.breakOn w user of
    (before, rest) | T.null rest -> Nothing
                   | otherwise -> Just (Span (T.length before) (T.length before + T.length w))

-- | @forbiddenIdentifiers comment forbids user@: tokens of the user region
-- (comments stripped) that appear in the forbid list.
forbiddenIdentifiers :: Text -> [Text] -> Text -> [Violation]
forbiddenIdentifiers comment forbids user =
  [ Violation "forbidden" (spanOf tok) ("`" <> tok <> "` is not available in this level. Prove it yourself or use the inventory.")
  | tok <- tokens (stripComments comment user), tok `elem` forbids ]
 where
  spanOf w = case T.breakOn w user of
    (before, rest) | T.null rest -> Nothing
                   | otherwise -> Just (Span (T.length before) (T.length before + T.length w))

-- | Remove line comments (@-- …@ or @# …@) and, for @--@, block comments @{- … -}@.
stripComments :: Text -> Text -> Text
stripComments comment t
  | comment == "--" = T.unlines (map dropLine (T.lines (dropBlocks t)))
  | otherwise       = T.unlines (map dropLine (T.lines t))
 where
  dropLine l = fst (T.breakOn comment l)
  dropBlocks s = case T.breakOn "{-" s of
    (before, rest)
      | T.null rest -> before
      | "{-#" `T.isPrefixOf` rest ->
          -- pragmas are kept so the pragma rule can see them
          let (prag, after) = T.breakOn "#-}" rest
          in before <> prag <> T.take 3 after <> dropBlocks (T.drop 3 after)
      | otherwise ->
          let (_, after) = T.breakOn "-}" rest
          in before <> " " <> dropBlocks (T.drop 2 after)

-- | Identifier-ish tokens: maximal runs of characters that are not
-- whitespace or Agda/Lean delimiters. Unicode symbols stay inside tokens, so
-- @+-comm@ and @≤-refl@ are single tokens.
tokens :: Text -> [Text]
tokens = filter (not . T.null) . T.split isDelim
 where
  isDelim c = isSpace c || c `elem` ("()[]{};,\"" :: String)
