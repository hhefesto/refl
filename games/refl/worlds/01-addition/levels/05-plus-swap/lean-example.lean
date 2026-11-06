-- @prelude
import Refl.World.Tutorial
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc)
-- @statement
theorem example_inner (x y z : MyNat) : (x + y) + z = (y + x) + z := by
-- @template
  sorry
-- @solution
  exact congrArg (· + z) (add_comm x y)
