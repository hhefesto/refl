-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem eq_irrelevant {x y : MyNat} (p q : x = y) : p = q := by
-- @template
  sorry
-- @solution
  rfl
