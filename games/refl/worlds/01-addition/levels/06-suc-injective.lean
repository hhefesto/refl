-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def pred : MyNat → MyNat
  | zero => zero
  | succ n => n

theorem succ_inj {x y : MyNat} (h : succ x = succ y) : x = y := by
-- @template
  sorry
-- @solution
  exact congrArg pred h
