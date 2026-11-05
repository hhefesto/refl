-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
example : ∀ n → n ≢ 0 → (n ≡ᵇ 0) ≡ false
-- @template
-- The complete worked proof is below.
-- @solution
example n notZero with n ≡ᵇ 0 in eq
... | true = ⊥-elim (notZero (≡ᵇ⇒≡ n 0 eq))
... | false = refl
