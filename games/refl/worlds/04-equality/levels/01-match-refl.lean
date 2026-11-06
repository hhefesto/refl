-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem cong' {A B : Type} (f : A → B) {x y : A} (p : x = y) : f x = f y := by
-- @template
  sorry
-- @solution
  cases p
  rfl
