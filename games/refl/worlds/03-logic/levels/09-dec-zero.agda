-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.DecZero where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
is-zero : (n : ℕ) → Dec (n ≡ zero)
-- @template
is-zero n = ?
-- @solution
is-zero zero = yes refl
is-zero (suc n) = no (λ ())
