-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def sumTo (f : MyNat → MyNat) : MyNat → MyNat
  | zero => zero
  | succ n => sumTo f n + f n

theorem sumTo_zero (n : MyNat) : sumTo (fun _ => zero) n = zero := by
-- @template
  sorry
-- @solution
  induction n with
  | zero => rfl
  | succ n ih => exact ih
