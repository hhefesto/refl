-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem contraposition {A B : Prop} (f : A → B) : ¬ B → ¬ A := by
-- @template
  sorry
-- @solution
  intro nb a
  exact nb (f a)
