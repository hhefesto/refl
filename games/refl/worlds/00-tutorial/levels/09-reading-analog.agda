-- @prelude
{-# OPTIONS --safe --without-K #-}
module Tutorial.ReadingAnalog where

open import Refl.Nat
open import Refl.Eq
-- @statement
analog₁ : ℕ → (ℕ → ℕ) → (ℕ → ℕ) → (ℕ → ℕ)
analog₁ δ h x̃ = λ t → h (x̃ (t + δ))

analog₁′ : ℕ → (ℕ → ℕ) → (ℕ → ℕ) → (ℕ → ℕ)

analog-same : ∀ δ h x̃ t → analog₁ δ h x̃ t ≡ analog₁′ δ h x̃ t
-- @template
analog₁′ δ h x̃ t = ?

analog-same δ h x̃ t = ?
-- @solution
analog₁′ δ h x̃ t = h (x̃ (t + δ))

analog-same δ h x̃ t = refl
