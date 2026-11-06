-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def count : MyNat → MyNat
  | zero => zero
  | succ n => count n + 1

theorem count_id (n : MyNat) : count n = n := by
-- @template
  sorry
-- @solution
  induction n with
  | zero => rfl
  | succ n ih => exact congrArg succ ih
