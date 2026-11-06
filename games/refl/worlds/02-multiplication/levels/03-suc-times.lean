-- @prelude
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
-- @statement
theorem succ_mul (x y : MyNat) : succ x * y = x * y + y := by
-- @template
  sorry
-- @solution
  induction y with
  | zero => rfl
  | succ y ih => rw [mul_succ, mul_succ, add_succ, add_succ, ih, add_right_comm]
