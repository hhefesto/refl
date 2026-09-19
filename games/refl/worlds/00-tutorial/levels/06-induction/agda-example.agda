-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
-- @statement
copy : ℕ → ℕ
copy zero = zero
copy (suc n) = suc (copy n)

example : ∀ n → copy n ≡ n
-- @template
-- The complete worked proof is below.
-- @solution
example zero = refl
example (suc n) = cong suc (example n)
