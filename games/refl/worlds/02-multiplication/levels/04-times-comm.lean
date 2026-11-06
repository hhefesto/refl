-- @prelude
import Refl.World.Multiplication
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
open Refl.World.Multiplication (zero_mul succ_mul)
-- @statement
theorem mul_comm (x y : MyNat) : x * y = y * x := by
-- @template
  sorry
-- @solution
  induction y with
  | zero => exact Eq.symm (zero_mul x)
  | succ y ih => rw [mul_succ, ih, succ_mul]
