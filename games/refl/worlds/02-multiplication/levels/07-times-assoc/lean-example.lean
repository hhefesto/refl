-- @prelude
import Refl.World.Multiplication
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
open Refl.World.Multiplication (mul_add)
-- @statement
theorem example_sum (a b c : MyNat) : a * b + a * c = a * (b + c) := by
-- @template
  sorry
-- @solution
  exact Eq.symm (mul_add a b c)
