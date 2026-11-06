-- @prelude
import Refl.World.Tutorial
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (succ_add)
-- @statement
theorem add_comm (x y : MyNat) : x + y = y + x := by
-- @template
  sorry
-- @solution
  induction y with
  | zero => exact Eq.symm (zero_add x)
  | succ y ih => rw [add_succ, ih, succ_add]
