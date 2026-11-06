-- @prelude
import Refl.World.Equality
open MyNat
open Refl.World.Logic (dec_eq)
open Refl.World.Equality (delta)
-- @statement
theorem example_diag (i : MyNat) : delta i i = 1 := by
-- @template
  sorry
-- @solution
  unfold delta
  cases dec_eq i i with
  | isTrue _ => rfl
  | isFalse n => exact absurd rfl n
