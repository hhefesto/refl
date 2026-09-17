-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.Forall where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
∀-× : ∀ {P Q : ℕ → Set} → (∀ n → P n × Q n) → (∀ n → P n) × (∀ n → Q n)
-- @template
∀-× h = ?
-- @solution
∀-× h = (λ n → proj₁ (h n)) , (λ n → proj₂ (h n))
