-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem example_chain {A B C : Prop} : (A → B) → (B → C) → A → C := by
-- @template
  sorry
-- @solution
  intro f g a
  exact g (f a)
