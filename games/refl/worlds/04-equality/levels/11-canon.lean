-- @prelude
import Refl.World.Logic
open MyNat
open Refl.World.Logic (dec_eq)
-- @statement
def canon {x y : MyNat} (p : x = y) : x = y :=
  match dec_eq x y with
  | isTrue q => q
  | isFalse nq => absurd p nq

theorem canon_inv {x y : MyNat} (p : x = y) : Eq.trans (Eq.symm (canon rfl)) (canon p) = p := by
-- @template
  sorry
-- @solution
  rfl
