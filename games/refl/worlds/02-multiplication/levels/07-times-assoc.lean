-- @prelude
import Refl.World.Multiplication
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
open Refl.World.Multiplication (mul_add)
-- @statement
theorem mul_assoc (x y z : MyNat) : (x * y) * z = x * (y * z) := by
-- @template
  sorry
-- @solution
  induction z with
  | zero => rfl
  | succ z ih => rw [mul_succ, mul_succ, mul_add, ih]
