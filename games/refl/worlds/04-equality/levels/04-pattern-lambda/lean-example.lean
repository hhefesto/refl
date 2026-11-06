-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_succ {a b : MyNat} : a = b → succ a = succ b := by
-- @template
  sorry
-- @solution
  exact fun | rfl => rfl
