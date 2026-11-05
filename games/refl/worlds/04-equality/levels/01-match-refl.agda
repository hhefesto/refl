-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.MatchRefl where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
cong′ : ∀ {A B : Set} (f : A → B) {x y : A} → x ≡ y → f x ≡ f y
-- @template
cong′ f p = ?
-- @solution
cong′ f refl = refl
