-- @prelude
import Refl.World.Multiplication
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
open Refl.World.Multiplication (one_mul)
-- @statement
theorem pow_two (x : MyNat) : x ^ (2 : MyNat) = x * x := by
-- @template
  sorry
-- @solution
  exact congrArg (· * x) (one_mul x)
