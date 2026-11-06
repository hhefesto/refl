-- @prelude
import Refl.World.Multiplication
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
open Refl.World.Multiplication (mul_one mul_comm)
-- @statement
theorem one_mul (x : MyNat) : 1 * x = x := by
-- @template
  sorry
-- @solution
  rw [mul_comm]
  exact mul_one x
