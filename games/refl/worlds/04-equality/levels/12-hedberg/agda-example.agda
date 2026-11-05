-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
open import Refl.World.Equality using (canon; canon-const; canon-inv)
open ≡-Reasoning
-- @statement
example : ∀ {x y z : ℕ} (e : x ≡ y) (p q : y ≡ z) → p ≡ q → trans e p ≡ trans e q
-- @template
-- The complete worked proof is below.
-- @solution
example e p q h =
  begin
    trans e p ≡⟨ cong (trans e) h ⟩
    trans e q ∎
