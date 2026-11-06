-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem trans_symm {A : Type} {x y : A} (e : x = y) : Eq.trans (Eq.symm e) e = rfl := by
-- @template
  sorry
-- @solution
  cases e
  rfl
