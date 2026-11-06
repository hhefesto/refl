-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_pair {P Q : MyNat → Prop} (p : ∀ n, P n) (q : ∀ n, Q n) : ∀ n, P n ∧ Q n := by
-- @template
  sorry
-- @solution
  intro n
  exact ⟨p n, q n⟩
