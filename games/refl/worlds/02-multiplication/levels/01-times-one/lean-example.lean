-- @prelude
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
-- @statement
theorem example_two (x : MyNat) : x * 2 = x + x := by
-- @template
  sorry
-- @solution
  exact congrArg (· + x) (zero_add x)
