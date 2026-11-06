-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_test (n : MyNat) (h : n ≠ zero) : isZero n = false := by
-- @template
  sorry
-- @solution
  generalize e : isZero n = b
  cases b with
  | true => exact absurd (isZero_true e) h
  | false => rfl
