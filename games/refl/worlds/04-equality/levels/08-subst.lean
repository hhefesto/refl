-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem trans' {x y z : MyNat} (p : x = y) (q : y = z) : x = z := by
-- @template
  sorry
-- @solution
  exact Eq.subst (motive := fun w => x = w) q p
