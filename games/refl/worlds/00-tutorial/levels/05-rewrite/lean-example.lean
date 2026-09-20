-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_sub (n : MyNat) (h : n = 4) : n + 1 = 5 := by
-- @template
  sorry
-- @solution
  rw [h]
  rfl
