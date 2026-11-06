-- @prelude
import Refl.World.Logic
open MyNat
open Refl.World.Logic (dec_eq)
-- @statement
def choose {A : Prop} : Decidable A → MyNat
  | isTrue _ => 1
  | isFalse _ => 0

theorem example_choose {A : Prop} (d : Decidable A) (a : A) : choose d = 1 := by
-- @template
  sorry
-- @solution
  cases d with
  | isTrue _ => rfl
  | isFalse n => exact absurd a n
