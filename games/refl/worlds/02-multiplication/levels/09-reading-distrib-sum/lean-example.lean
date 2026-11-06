-- @prelude
import Refl.World.Multiplication
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
open Refl.World.Multiplication (mul_add)
open Refl.World.Addition (sumTo)
-- @statement
theorem example_const (c n : MyNat) : sumTo (fun _ => c * 0) n = c * 0 := by
-- @template
  sorry
-- @solution
  induction n with
  | zero => rfl
  | succ n ih => exact ih
