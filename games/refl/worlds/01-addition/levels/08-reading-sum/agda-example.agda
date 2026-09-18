-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
-- @statement
count : ℕ → ℕ
count zero = zero
count (suc n) = count n + 1

count-id : ∀ (n : ℕ) → count n ≡ n
-- @template
-- The complete worked proof is below.
-- @solution
count-id zero = refl
count-id (suc n) = cong suc (count-id n)
