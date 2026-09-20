-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem same (x : MyNat) : x = x := by
-- @template
  sorry
-- @solution
  rfl
