-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem two_three (x y : MyNat) (p : x = 2) (q : y = 3) : x + y = 5 := by
-- @template
  sorry
-- @solution
  rw [p, q]
  rfl
