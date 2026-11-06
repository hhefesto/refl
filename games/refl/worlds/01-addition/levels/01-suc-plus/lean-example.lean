-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_succ (x y : MyNat) : succ x + y = x + succ y := by
-- @template
  sorry
-- @solution
  induction y with
  | zero => rfl
  | succ y ih => rw [add_succ, ih]; rfl
