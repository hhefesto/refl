-- @prelude
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
-- @statement
theorem example_outer (a b c : MyNat) : succ ((a + b) + c) = succ (a + (b + c)) := by
-- @template
  sorry
-- @solution
  rw [add_assoc]
