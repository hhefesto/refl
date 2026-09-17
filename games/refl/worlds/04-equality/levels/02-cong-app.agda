-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.CongApp where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
cong-app : ∀ {A B : Set} {f g : A → B} → f ≡ g → ∀ x → f x ≡ g x

infix 4 _≗_
_≗_ : ∀ {A B : Set} → (A → B) → (A → B) → Set
f ≗ g = ∀ x → f x ≡ g x

≗-trans : ∀ {A B : Set} {f g h : A → B} → f ≗ g → g ≗ h → f ≗ h
-- @template
cong-app e x = ?

≗-trans p q x = ?
-- @solution
cong-app refl x = refl

≗-trans p q x = trans (p x) (q x)
