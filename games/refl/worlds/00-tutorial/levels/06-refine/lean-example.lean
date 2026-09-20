-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_nested (n : MyNat) : (n + 1) + 1 = n + 2 := by
-- @template
  sorry
-- @solution
  rfl
