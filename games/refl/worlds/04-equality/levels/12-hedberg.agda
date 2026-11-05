-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.Hedberg where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
open import Refl.World.Equality using (canon; canon-const; canon-inv)
open ≡-Reasoning
-- @statement
≡-irrelevant : ∀ {x y : ℕ} (p q : x ≡ y) → p ≡ q
-- @template
≡-irrelevant p q =
  begin
    p                                    ≡⟨ ? ⟩
    trans (sym (canon refl)) (canon p)   ≡⟨ ? ⟩
    trans (sym (canon refl)) (canon q)   ≡⟨ ? ⟩
    q                                    ∎
-- @solution
≡-irrelevant p q =
  begin
    p                                    ≡⟨ sym (canon-inv p) ⟩
    trans (sym (canon refl)) (canon p)   ≡⟨ cong (trans (sym (canon refl))) (canon-const p q) ⟩
    trans (sym (canon refl)) (canon q)   ≡⟨ canon-inv q ⟩
    q                                    ∎
