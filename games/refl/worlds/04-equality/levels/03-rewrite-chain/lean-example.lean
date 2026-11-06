-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_five (a b : MyNat) (p : a = 1) (q : b = 4) : a + b = 5 := by
-- @template
  sorry
-- @solution
  rw [p, q]
  rfl
