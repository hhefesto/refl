-- @prelude
import Refl.World.Tutorial
import Refl.World.Addition
open MyNat
open Refl.World.Tutorial (zero_add)
open Refl.World.Addition (add_comm add_assoc)
-- @statement
theorem example_chain {a b c : MyNat} (p : a = b) (q : b = c) : succ a = succ c := by
-- @template
  sorry
-- @solution
  calc succ a = succ b := congrArg succ p
    _ = succ c := congrArg succ q
