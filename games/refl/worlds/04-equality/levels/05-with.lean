-- @prelude
import Refl.World.Logic
open MyNat
open Refl.World.Logic (dec_eq)
-- @statement
def delta (i j : MyNat) : MyNat :=
  match dec_eq i j with
  | isTrue _ => 1
  | isFalse _ => 0

theorem delta_diag (i : MyNat) : delta i i = 1 := by
-- @template
  sorry
-- @solution
  unfold delta
  cases dec_eq i i with
  | isTrue _ => rfl
  | isFalse n => exact absurd rfl n
