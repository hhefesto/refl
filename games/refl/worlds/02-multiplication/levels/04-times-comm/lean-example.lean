-- @prelude
import Refl.World.Multiplication
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
open Refl.World.Multiplication (zero_mul succ_mul)
-- @statement
theorem example_zero (x : MyNat) : 0 * x = x * 0 := by
-- @template
  sorry
-- @solution
  exact zero_mul x
