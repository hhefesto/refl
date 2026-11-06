-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_or (s : False ∨ True) : True := by
-- @template
  sorry
-- @solution
  cases s with
  | inl h => cases h
  | inr t => exact t
