-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem use_h (x : MyNat) (h : x = 3) : x + 2 = 5 := by
-- @template
  sorry
-- @solution
  rw [h]
  rfl
