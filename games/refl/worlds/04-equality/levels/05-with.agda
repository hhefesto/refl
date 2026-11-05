-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.With where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
open import Refl.World.Logic using (_≟_)
-- @statement
δ : ℕ → ℕ → ℕ
δ i j with i ≟ j
... | yes _ = 1
... | no  _ = 0

δ-diag : ∀ (i : ℕ) → δ i i ≡ 1
-- @template
δ-diag i = ?
-- @solution
δ-diag i with i ≟ i
... | yes _ = refl
... | no ¬p = ⊥-elim (¬p refl)
