-- @prelude
import Refl.World.Tutorial
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc)
-- @statement
theorem add_left_comm (x y z : MyNat) : x + (y + z) = y + (x + z) := by
-- @template
  sorry
-- @solution
  calc x + (y + z) = (x + y) + z := Eq.symm (add_assoc x y z)
    _ = (y + x) + z := congrArg (· + z) (add_comm x y)
    _ = y + (x + z) := add_assoc y x z
