-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def Pointwise {A B : Type} (f g : A → B) : Prop := ∀ x, f x = g x

theorem pointwise_of_eq {A B : Type} {f g h : A → B} (e : f = g) (q : Pointwise g h) :
    Pointwise f h := by
-- @template
  sorry
-- @solution
  intro x
  cases e
  exact q x
