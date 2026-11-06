-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_nest {A B C : Prop} (p : (A ∧ B) ∧ C) : A ∧ (B ∧ C) := by
-- @template
  sorry
-- @solution
  cases p with
  | intro ab c =>
    cases ab with
    | intro a b => exact ⟨a, ⟨b, c⟩⟩
