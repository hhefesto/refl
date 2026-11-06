-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem add_assoc (x y z : MyNat) : (x + y) + z = x + (y + z) := by
-- @template
  sorry
-- @solution
  induction z with
  | zero => rfl
  | succ z ih => rw [add_succ, add_succ, add_succ, ih]
