-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem zero_ne_succ (n : MyNat) : zero ≠ succ n := by
-- @template
  sorry
-- @solution
  intro h
  cases h
