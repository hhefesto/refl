-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem two_plus_two_by_hand : (2 : MyNat) + 2 = 4 := by
-- @template
  conv =>
    lhs
    change succ 1 + succ 1   -- one step from the left, done for you
    change ?_                -- replace the hole: your step from the left
  conv =>
    rhs
    change succ 3            -- one step from the right, done for you
    change ?_                -- replace the hole: your step from the right
-- @solution
  conv =>
    lhs
    change succ 1 + succ 1
    change succ (succ 2)
  conv =>
    rhs
    change succ 3
    change succ (succ 2)
