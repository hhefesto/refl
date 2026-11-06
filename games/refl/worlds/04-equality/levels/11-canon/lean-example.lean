-- @prelude
import Refl.World.Logic
open MyNat
open Refl.World.Logic (dec_eq)
-- @statement
theorem example_any (x : MyNat) (p q : x = x) : p = q := by
-- @template
  sorry
-- @solution
  rfl
