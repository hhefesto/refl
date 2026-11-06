-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem ex_falso {A : Prop} (h : False) : A ∧ True := by
-- @template
  sorry
-- @solution
  constructor
  · cases h
  · exact True.intro
