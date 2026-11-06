-- @prelude
import Refl.World.Equality
open MyNat
open Refl.World.Logic (dec_eq)
open Refl.World.Equality (delta)
-- @statement
theorem delta_sym (i j : MyNat) : delta i j = delta j i := by
-- @template
  sorry
-- @solution
  unfold delta
  cases dec_eq i j with
  | isTrue p =>
    cases dec_eq j i with
    | isTrue _ => rfl
    | isFalse nq => exact absurd (Eq.symm p) nq
  | isFalse np =>
    cases dec_eq j i with
    | isTrue q => exact absurd (Eq.symm q) np
    | isFalse _ => rfl
