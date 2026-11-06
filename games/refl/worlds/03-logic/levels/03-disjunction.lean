-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem or_swap {A B : Prop} (s : A ∨ B) : B ∨ A := by
-- @template
  sorry
-- @solution
  cases s with
  | inl a => exact Or.inr a
  | inr b => exact Or.inl b
