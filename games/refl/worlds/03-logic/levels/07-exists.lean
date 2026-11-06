-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem witness : ∃ n : MyNat, n + 1 = 3 := by
-- @template
  sorry
-- @solution
  exact ⟨2, rfl⟩
