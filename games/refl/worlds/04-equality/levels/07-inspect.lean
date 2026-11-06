-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def g (n : MyNat) : MyNat :=
  match isZero n with
  | true => 1
  | false => n

theorem g_nonzero (n : MyNat) (h : n ≠ zero) : g n = n := by
-- @template
  sorry
-- @solution
  unfold g
  generalize e : isZero n = b
  cases b with
  | true => exact absurd (isZero_true e) h
  | false => rfl
