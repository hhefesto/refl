-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_motive {A : Type} {x y : A} (p : x = y) (P : A → Prop) (px : P x) : P y := by
-- @template
  sorry
-- @solution
  cases p
  exact px
