-- @prelude
import Refl.World.Logic
open MyNat
open Refl.World.Logic (and_swap)
-- @statement
theorem and_swap_iff {A B : Prop} : A ∧ B ↔ B ∧ A := by
-- @template
  sorry
-- @solution
  exact ⟨and_swap, and_swap⟩
