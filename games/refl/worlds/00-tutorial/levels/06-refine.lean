-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem three_steps (x : MyNat) : (x + 2) + 1 = x + 3 := by
-- @template
  sorry
-- @solution
  rfl
