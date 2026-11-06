-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def example_dec : Decidable (succ zero = succ (succ zero)) := by
-- @template
  sorry
-- @solution
  exact isFalse (fun h => by cases h)
