-- @prelude
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
-- @statement
theorem example_plus (x y z : MyNat) : x * (y + z) + x = x * y + (x * z + x) := by
-- @template
  sorry
-- @solution
  induction z with
  | zero => exact congrArg (x * y + ·) (Eq.symm (zero_add x))
  | succ z ih => rw [add_succ, mul_succ, ih, add_assoc, add_assoc, mul_succ, add_assoc]
