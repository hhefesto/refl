-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
record Seen (n : ℕ) (b : Bool) : Set where
  constructor seen
  field evidence : (n ≡ᵇ 0) ≡ b

observe : ∀ n → Seen n (n ≡ᵇ 0)
observe n = seen refl

example : ∀ n → n ≢ 0 → (n ≡ᵇ 0) ≡ false
-- @template
-- The complete worked proof is below.
-- @solution
example n notZero with n ≡ᵇ 0 | observe n
... | true | seen eq = ⊥-elim (notZero (≡ᵇ⇒≡ n 0 eq))
... | false | seen eq = refl
