-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_map {a b : MyNat} (h : a = b) : a + 2 = b + 2 := by
-- @template
  sorry
-- @solution
  rw [h]
