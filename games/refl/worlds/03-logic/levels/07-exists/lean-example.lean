-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_four : ∃ n : MyNat, n + 2 = 6 := by
-- @template
  sorry
-- @solution
  exact ⟨4, rfl⟩
