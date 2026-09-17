-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem flip_chain {x y z : MyNat} (p : y = x) (q : y = z) : x = z := by
-- @template
  sorry
-- @solution
  rw [← p, q]
