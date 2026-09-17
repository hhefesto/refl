-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem zero_add (x : MyNat) : 0 + x = x := by
-- @template
  sorry
-- @solution
  induction x with
  | zero => rfl
  | succ n ih => rw [add_succ, ih]
