-- @prelude
import Refl.World.Logic
open MyNat
open Refl.World.Logic (and_swap)
-- @statement
theorem example_true {A : Prop} : A ↔ A ∧ True := by
-- @template
  sorry
-- @solution
  exact ⟨fun a => ⟨a, True.intro⟩, fun p => p.left⟩
