-- @prelude
import Refl.World.Multiplication
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc add_right_comm add_left_comm)
open Refl.World.Multiplication (mul_add)
open Refl.World.Addition (sumTo)
-- @statement
theorem sum_factor (c : MyNat) (f : MyNat → MyNat) (n : MyNat) :
    sumTo (fun i => c * f i) n = c * sumTo f n := by
-- @template
  sorry
-- @solution
  induction n with
  | zero => rfl
  | succ n ih => exact Eq.trans (congrArg (· + c * f n) ih) (Eq.symm (mul_add c (sumTo f n) (f n)))
