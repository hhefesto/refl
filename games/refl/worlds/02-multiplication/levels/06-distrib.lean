-- @prelude
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
-- @statement
theorem mul_add (x y z : MyNat) : x * (y + z) = x * y + x * z := by
-- @template
  sorry
-- @solution
  induction z with
  | zero => rfl
  | succ z ih => rw [add_succ, mul_succ, mul_succ, ih, add_assoc]
