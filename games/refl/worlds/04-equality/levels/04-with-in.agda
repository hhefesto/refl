-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.WithIn where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
f : ℕ → ℕ
f n with n ≡ᵇ 0
... | true  = 1
... | false = n

f-nonzero : ∀ (n : ℕ) → n ≢ 0 → f n ≡ n
-- @template
f-nonzero n h = ?
-- @solution
f-nonzero n h with n ≡ᵇ 0 in eq
... | true  = ⊥-elim (h (≡ᵇ⇒≡ n 0 eq))
... | false = refl
