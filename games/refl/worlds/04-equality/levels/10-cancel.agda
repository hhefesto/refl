-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.Cancel where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
trans-symˡ : ∀ {A : Set} {x y : A} (e : x ≡ y) → trans (sym e) e ≡ refl
-- @template
trans-symˡ e = ?
-- @solution
trans-symˡ refl = refl
