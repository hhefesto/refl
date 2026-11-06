-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem J {A : Type} {x : A} (P : ∀ y, x = y → Prop) (d : P x rfl) {y : A} (p : x = y) : P y p := by
-- @template
  sorry
-- @solution
  cases p
  exact d
