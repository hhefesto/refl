-- | Rendering of the commands Agda's @--interaction-json@ mode reads on stdin.
-- Names and argument shapes follow @Agda.Interaction.Base.Interaction'@ in
-- Agda 2.8.0 (note @Cmd_autoOne@, not the older @Cmd_auto@).
module Refl.Language.Agda.IOTCM
  ( Cmd (..)
  , Rewrite (..)
  , renderIOTCM
  , rewriteOf
  ) where

import           Data.Text           (Text)
import qualified Data.Text           as T

import           Refl.Protocol.Types (Normalisation (..))

data Rewrite = AsIs | Instantiated | HeadNormal | Simplified | Normalised
  deriving (Eq, Show)

rewriteOf :: Normalisation -> Rewrite
rewriteOf = \case
  NormAsIs         -> AsIs
  NormInstantiated -> Instantiated
  NormHeadNormal   -> HeadNormal
  NormSimplified   -> Simplified
  NormNormalised   -> Normalised

data Cmd
  = ALoad
  | AGoalTypeContext Rewrite Int
  | AContext Rewrite Int
  | AGive Int Text
  | ARefineOrIntro Bool Int Text
  | AMakeCase Int Text
  | AAutoOne Int
  | AInfer Rewrite Int Text
  | ACompute Int Text
  | AHelperFunction Rewrite Int Text
  | ASolveAll Rewrite
  | AShowVersion
  | AAbort
  | AExit
  deriving (Eq, Show)

-- | One IOTCM line (without the trailing newline).
renderIOTCM :: FilePath -> Cmd -> Text
renderIOTCM file cmd =
  "IOTCM " <> str (T.pack file) <> " NonInteractive Direct (" <> body <> ")"
 where
  body = case cmd of
    ALoad                    -> "Cmd_load " <> str (T.pack file) <> " []"
    AGoalTypeContext r i     -> "Cmd_goal_type_context " <> rw r <> " " <> int i <> " noRange \"\""
    AContext r i             -> "Cmd_context " <> rw r <> " " <> int i <> " noRange \"\""
    AGive i e                -> "Cmd_give WithoutForce " <> int i <> " noRange " <> str e
    ARefineOrIntro b i e     -> "Cmd_refine_or_intro " <> bool b <> " " <> int i <> " noRange " <> str e
    AMakeCase i v            -> "Cmd_make_case " <> int i <> " noRange " <> str v
    AAutoOne i               -> "Cmd_autoOne AsIs " <> int i <> " noRange \"\""
    AInfer r i e             -> "Cmd_infer " <> rw r <> " " <> int i <> " noRange " <> str e
    ACompute i e             -> "Cmd_compute DefaultCompute " <> int i <> " noRange " <> str e
    AHelperFunction r i e    -> "Cmd_helper_function " <> rw r <> " " <> int i <> " noRange " <> str e
    ASolveAll r              -> "Cmd_solveAll " <> rw r
    AShowVersion             -> "Cmd_show_version"
    AAbort                   -> "Cmd_abort"
    AExit                    -> "Cmd_exit"
  rw = T.pack . show
  int = T.pack . show
  bool b = if b then "True" else "False"
  -- Agda parses the string with Haskell's Read, so Show's escaping is exact.
  str = T.pack . show . T.unpack
