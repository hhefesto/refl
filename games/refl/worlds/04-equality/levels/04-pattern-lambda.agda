-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.PatternLambda where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
sym′ : ∀ {A : Set} {x y : A} → x ≡ y → y ≡ x
-- @template
sym′ = ?
-- @solution
sym′ = λ { refl → refl }
