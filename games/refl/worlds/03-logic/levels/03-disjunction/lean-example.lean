-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_same {A : Prop} (s : A ∨ A) : A := by
-- @template
  sorry
-- @solution
  cases s with
  | inl a => exact a
  | inr a => exact a
