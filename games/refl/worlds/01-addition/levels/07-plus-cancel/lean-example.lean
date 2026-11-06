-- @prelude
import Refl.World.Tutorial
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (succ_inj)
-- @statement
def wrap : MyNat → MyNat → MyNat
  | zero, x => x
  | succ n, x => succ (wrap n x)

theorem example_wrap (n x y : MyNat) (h : wrap n x = wrap n y) : x = y := by
-- @template
  sorry
-- @solution
  induction n with
  | zero => exact h
  | succ n ih => exact ih (succ_inj h)
