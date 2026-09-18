-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_identity (n : MyNat) : n + 0 = n := by
-- @template
  sorry
-- @solution
  rfl
