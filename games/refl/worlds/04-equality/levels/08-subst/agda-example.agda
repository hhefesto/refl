-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
example : ∀ {a b : ℕ} → a ≡ b → a + 1 ≡ 5 → b + 1 ≡ 5
-- @template
-- The complete worked proof is below.
-- @solution
example p h = subst (λ n → n + 1 ≡ 5) p h
