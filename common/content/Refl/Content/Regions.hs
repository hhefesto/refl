-- | A level source file is four regions separated by full-line markers made of
-- the language's comment prefix and an @\@name@:
--
-- > -- @prelude
-- > {-# OPTIONS --safe --without-K #-}
-- > module Tutorial.Refl where
-- > open import Refl.Nat
-- > -- @statement
-- > lemma : ∀ (n : ℕ) → n ≡ n
-- > -- @template
-- > lemma n = ?
-- > -- @solution
-- > lemma n = refl
--
-- The prelude and statement are fixed and spliced around the player's text;
-- the template is the initial player text; the solution is stripped from the
-- manifest and type-checked by @refl-check-levels@.
module Refl.Content.Regions
  ( Regions (..)
  , parseRegions
  , moduleNameOf
  ) where

import           Data.Char (isSpace)
import           Data.Text (Text)
import qualified Data.Text as T

data Regions = Regions
  { rPrelude   :: Text
  , rStatement :: Text
  , rTemplate  :: Text
  , rSolution  :: Text
  } deriving (Eq, Show)

-- | @parseRegions commentPrefix source@. Markers must appear exactly once
-- each, in order; marker lines are stripped; each region keeps its own
-- trailing newline so splicing is a plain concatenation.
parseRegions :: Text -> Text -> Either Text Regions
parseRegions comment src = do
  let ls = T.lines src
      isMarker name l = T.strip l == comment <> " @" <> name
      cut name rest = case break (isMarker name) rest of
        (before, _ : after) -> Right (before, after)
        (_, [])             -> Left ("missing marker `" <> comment <> " @" <> name <> "`")
  (junk, afterPrelude) <- cut "prelude" ls
  if any (not . T.all isSpace) junk
    then Left "text before the @prelude marker"
    else Right ()
  (prelude, afterStatement) <- cut "statement" afterPrelude
  (statement, afterTemplate) <- cut "template" afterStatement
  (template, solution) <- cut "solution" afterTemplate
  mapM_ (dupCheck ls) ["prelude", "statement", "template", "solution"]
  pure Regions
    { rPrelude   = T.unlines prelude
    , rStatement = T.unlines statement
    , rTemplate  = T.unlines template
    , rSolution  = T.unlines solution
    }
 where
  dupCheck ls name =
    let n = length (filter (\l -> T.strip l == comment <> " @" <> name) ls)
    in if n == 1 then Right () else Left ("marker @" <> name <> " appears " <> T.pack (show n) <> " times")

-- | The module name declared in an Agda prelude (@module A.B where@), used
-- to place the file at @A/B.agda@ in the session directory.
moduleNameOf :: Text -> Maybe Text
moduleNameOf prelude =
  case [ w | l <- T.lines prelude, ("module" : w : _) <- [T.words l] ] of
    (m : _) -> Just m
    []      -> Nothing
