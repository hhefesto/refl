-- @prelude
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
-- @statement
theorem mul_one (x : MyNat) : x * 1 = x := by
-- @template
  sorry
-- @solution
  exact zero_add x
