-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
open import Refl.World.Logic using (_≟_)
open import Refl.World.Equality using (δ)
-- @statement
δ-diag : ∀ (i : ℕ) → δ i i ≡ 1
-- @template
-- The complete worked proof is below.
-- @solution
δ-diag i with i ≟ i
... | yes _ = refl
... | no ¬p = ⊥-elim (¬p refl)
