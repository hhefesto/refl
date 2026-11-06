-- @prelude
import Refl.World.Tutorial
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc)
-- @statement
theorem add_right_comm (x y z : MyNat) : (x + y) + z = (x + z) + y := by
-- @template
  calc (x + y) + z = x + (y + z) := sorry
    _ = x + (z + y) := sorry
    _ = (x + z) + y := sorry
-- @solution
  calc (x + y) + z = x + (y + z) := add_assoc x y z
    _ = x + (z + y) := congrArg (x + ·) (add_comm y z)
    _ = (x + z) + y := Eq.symm (add_assoc x z y)
