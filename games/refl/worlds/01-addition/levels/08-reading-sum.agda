-- @prelude
{-# OPTIONS --safe --without-K #-}
module Addition.ReadingSum where

open import Refl.Nat
open import Refl.Eq
-- @statement
sumTo : (ℕ → ℕ) → ℕ → ℕ
sumTo f zero = zero
sumTo f (suc n) = sumTo f n + f n

sumTo-zero : ∀ (n : ℕ) → sumTo (λ _ → zero) n ≡ zero
-- @template
sumTo-zero n = ?
-- @solution
sumTo-zero zero = refl
sumTo-zero (suc n) = sumTo-zero n
