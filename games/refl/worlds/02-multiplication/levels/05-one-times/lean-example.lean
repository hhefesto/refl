-- @prelude
import Refl.World.Multiplication
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
open Refl.World.Multiplication (mul_one mul_comm)
-- @statement
theorem example_plus (x : MyNat) : 1 * x + 0 = x := by
-- @template
  sorry
-- @solution
  exact Eq.trans (mul_comm 1 x) (mul_one x)
