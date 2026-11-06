-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem succ_add (x y : MyNat) : succ x + y = succ (x + y) := by
-- @template
  sorry
-- @solution
  induction y with
  | zero => rfl
  | succ y ih => rw [add_succ, add_succ, ih]
