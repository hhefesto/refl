-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_side {P Q : MyNat → Prop} (h : ∀ n, P n ∧ Q n) (n : MyNat) : Q n ∨ P n := by
-- @template
  sorry
-- @solution
  exact Or.inl (h n).right
