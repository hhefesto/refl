-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
un : ℕ → ℕ
un zero = zero
un (suc n) = n

example : ∀ {a b : ℕ} → suc (suc a) ≡ suc (suc b) → a ≡ b
-- @template
-- The complete worked proof is below.
-- @solution
example h = cong (λ n → un (un n)) h
