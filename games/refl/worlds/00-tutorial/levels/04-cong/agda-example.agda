-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
-- @statement
example : ∀ {a b : ℕ} → a ≡ b → (a + 2) ≡ (b + 2)
-- @template
-- The complete worked proof is below.
-- @solution
example h = cong (λ n → n + 2) h
