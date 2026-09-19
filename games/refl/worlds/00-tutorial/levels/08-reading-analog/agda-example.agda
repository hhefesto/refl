-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
-- @statement
shift : ℕ → ℕ → ℕ
shift k = λ n → n + k

shift′ : ℕ → ℕ → ℕ
shift′ k n = n + k

example : ∀ k n → shift k n ≡ shift′ k n
-- @template
-- The complete worked proof is below.
-- @solution
example k n = refl
