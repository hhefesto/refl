-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_refl {A : Type} {x y : A} (p : x = y) : Eq.trans p rfl = p := by
-- @template
  sorry
-- @solution
  cases p
  rfl
