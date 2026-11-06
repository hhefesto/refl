-- @prelude
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
-- @statement
def zeros : MyNat → MyNat
  | zero => zero
  | succ n => zeros n + zero

theorem example_zeros (n : MyNat) : zeros n = zero := by
-- @template
  sorry
-- @solution
  induction n with
  | zero => rfl
  | succ n ih => exact ih
