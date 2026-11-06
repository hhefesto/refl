-- @prelude
import Refl.World.Tutorial
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (succ_inj)
-- @statement
theorem add_right_cancel (x y z : MyNat) (h : x + z = y + z) : x = y := by
-- @template
  sorry
-- @solution
  induction z with
  | zero => exact h
  | succ z ih => exact ih (succ_inj h)
