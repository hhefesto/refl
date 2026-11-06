-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def is_zero (n : MyNat) : Decidable (n = zero) := by
-- @template
  sorry
-- @solution
  cases n with
  | zero => exact isTrue rfl
  | succ n => exact isFalse (fun h => by cases h)
