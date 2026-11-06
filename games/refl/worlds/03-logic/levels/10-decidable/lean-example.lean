-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def example_one (n : MyNat) : Decidable (n = succ zero) :=
-- @template
  sorry
-- @solution
  match n with
  | zero => isFalse (fun h => by cases h)
  | succ zero => isTrue rfl
  | succ (succ _) => isFalse (fun h => by cases h)
