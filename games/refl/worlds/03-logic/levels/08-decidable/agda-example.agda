-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
example : (n : ℕ) → Dec (n ≡ zero)
-- @template
-- The complete worked proof is below.
-- @solution
example zero = yes refl
example (suc n) = no (λ ())
