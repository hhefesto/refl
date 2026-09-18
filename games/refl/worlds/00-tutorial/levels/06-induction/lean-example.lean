-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def copy : MyNat → MyNat
  | .zero => .zero
  | .succ n => .succ (copy n)

theorem example_copy (n : MyNat) : copy n = n := by
-- @template
  sorry
-- @solution
  induction n with
  | zero => rfl
  | succ k ih => rw [copy, ih]
