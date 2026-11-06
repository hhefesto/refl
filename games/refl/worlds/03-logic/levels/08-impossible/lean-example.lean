-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_ne : ¬ (succ zero = succ (succ zero)) := by
-- @template
  sorry
-- @solution
  intro h
  cases h
