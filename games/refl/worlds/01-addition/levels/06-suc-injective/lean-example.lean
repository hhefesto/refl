-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def un : MyNat → MyNat
  | zero => zero
  | succ n => n

theorem example_two {a b : MyNat} (h : succ (succ a) = succ (succ b)) : a = b := by
-- @template
  sorry
-- @solution
  exact congrArg (fun n => un (un n)) h
