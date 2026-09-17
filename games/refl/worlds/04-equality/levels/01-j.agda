-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.J where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
J : ∀ {A : Set} {x : A} (P : ∀ y → x ≡ y → Set) → P x refl → ∀ {y} (p : x ≡ y) → P y p
-- @template
J P d p = ?
-- @solution
J P d refl = d
