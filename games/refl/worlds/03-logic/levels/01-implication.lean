-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem modus_ponens {A B : Prop} : A → (A → B) → B := by
-- @template
  sorry
-- @solution
  intro a f
  exact f a
