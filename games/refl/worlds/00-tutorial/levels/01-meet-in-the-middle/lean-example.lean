-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_sum : (3 : MyNat) + 1 = 4 := by
-- @template
  sorry
-- @solution
  conv =>
    lhs
    change succ 3
  conv =>
    rhs
    change succ 3
