-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def f (n : MyNat) : MyNat :=
  match isZero n with
  | true => 1
  | false => n

theorem f_nonzero (n : MyNat) (h : n ≠ zero) : f n = n := by
-- @template
  sorry
-- @solution
  unfold f
  cases e : isZero n with
  | true => exact absurd (isZero_true e) h
  | false => rfl
