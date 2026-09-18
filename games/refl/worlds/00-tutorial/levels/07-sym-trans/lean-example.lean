-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_chain {a b c : MyNat} (p : a = b) (q : c = b) : a = c := by
-- @template
  sorry
-- @solution
  rw [p, q]
