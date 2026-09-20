-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem two_plus_two_by_hand : (2 : MyNat) + 2 = 4 := by
-- @template
  conv =>
    lhs
    change (2 : MyNat) + 2   -- replace with where the left endpoint lands
  conv =>
    rhs
    change 4                 -- replace with where the right endpoint lands
-- @solution
  conv =>
    lhs
    change succ (succ 2)
  conv =>
    rhs
    change succ (succ 2)
