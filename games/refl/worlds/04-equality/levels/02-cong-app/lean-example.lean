-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_flip {A B : Type} {f g : A → B} (p : ∀ x, f x = g x) (x : A) : g x = f x := by
-- @template
  sorry
-- @solution
  exact Eq.symm (p x)
