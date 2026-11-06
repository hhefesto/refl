-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_add {a b : MyNat} (p : a = b) : a + 2 = b + 2 := by
-- @template
  sorry
-- @solution
  cases p
  rfl
