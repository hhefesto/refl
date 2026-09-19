-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_sum : (3 : MyNat) + 1 = 4 := by
-- @template
  sorry
-- @solution
  change succ (succ (succ (succ zero))) = succ (succ (succ (succ zero)))
  rfl
