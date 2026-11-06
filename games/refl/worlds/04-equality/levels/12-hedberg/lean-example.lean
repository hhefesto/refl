-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_irrelevant {P : Prop} (p q : P) : p = q := by
-- @template
  sorry
-- @solution
  rfl
