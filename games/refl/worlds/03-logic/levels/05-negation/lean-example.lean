-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_not_not {A : Prop} (a : A) : ¬ ¬ A := by
-- @template
  sorry
-- @solution
  intro notA
  exact notA a
