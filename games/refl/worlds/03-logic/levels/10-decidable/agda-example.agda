-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
example : (n : ℕ) → Dec (n ≡ 1)
-- @template
-- The complete worked proof is below.
-- @solution
example zero = no (λ ())
example (suc zero) = yes refl
example (suc (suc n)) = no (λ ())
