-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem and_swap {A B : Prop} (p : A ∧ B) : B ∧ A := by
-- @template
  sorry
-- @solution
  cases p with
  | intro a b => exact ⟨b, a⟩
