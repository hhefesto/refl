-- @prelude
import Refl.World.Tutorial
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (succ_add)
-- @statement
theorem example_one (x : MyNat) : x + 1 = 1 + x := by
-- @template
  sorry
-- @solution
  exact Eq.symm (Eq.trans (succ_add zero x) (congrArg succ (zero_add x)))
