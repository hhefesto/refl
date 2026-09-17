-- | Language-agnostic verdict assembly.
module Refl.Verify
  ( verdictFrom
  , rejected
  ) where

import           Data.Text           (Text)
import qualified Data.Text           as T

import           Refl.Protocol.Types

-- | Rejected if static rules fired, Failed if any error diagnostic, Unsolved
-- if goals remain, else Solved.
verdictFrom :: [Violation] -> [Diagnostic] -> Int -> Verdict
verdictFrom vs ds goals
  | not (null vs) = Rejected vs
  | any ((== SevError) . diagSeverity) ds = Failed
  | goals > 0 = Unsolved goals
  | otherwise = Solved

-- | A result that never reached the prover.
rejected :: [Violation] -> CheckResult
rejected vs = CheckResult
  { crHoles = []
  , crDiagnostics = [ Diagnostic SevError (vSpan v) (vMessage v) | v <- vs ]
  , crHighlight = []
  , crVerdict = Rejected vs
  , crStatus = summary
  , crExtras = "null"
  }
 where
  summary :: Text
  summary = "Rejected: " <> T.intercalate "; " (map vRule vs)
