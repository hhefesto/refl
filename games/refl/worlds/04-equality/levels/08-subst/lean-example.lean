-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_move {a b : MyNat} (p : a = b) (h : a + 1 = 5) : b + 1 = 5 := by
-- @template
  sorry
-- @solution
  exact Eq.subst (motive := fun n => n + 1 = 5) p h
