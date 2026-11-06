-- @prelude
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
-- @statement
theorem zero_mul (x : MyNat) : 0 * x = 0 := by
-- @template
  sorry
-- @solution
  induction x with
  | zero => rfl
  | succ x ih => exact ih
