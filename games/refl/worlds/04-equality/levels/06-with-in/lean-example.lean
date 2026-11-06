-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_test (n : MyNat) (h : n ≠ zero) : isZero n = false := by
-- @template
  sorry
-- @solution
  cases e : isZero n with
  | true => exact absurd (isZero_true e) h
  | false => rfl
