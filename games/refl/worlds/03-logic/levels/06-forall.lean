-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem forall_split {P Q : MyNat → Prop} (h : ∀ n, P n ∧ Q n) : (∀ n, P n) ∧ (∀ n, Q n) := by
-- @template
  sorry
-- @solution
  constructor
  · intro n
    exact (h n).left
  · intro n
    exact (h n).right
