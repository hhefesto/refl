-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
example : ∀ {P Q : ℕ → Set} → (∀ n → P n × Q n) → ∀ n → Q n ⊎ P n
-- @template
-- The complete worked proof is below.
-- @solution
example h n = inj₁ (proj₂ (h n))
