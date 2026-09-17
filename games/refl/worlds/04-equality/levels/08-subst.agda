-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.Subst where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
trans′ : ∀ {x y z : ℕ} → x ≡ y → y ≡ z → x ≡ z
-- @template
trans′ p q = ?
-- @solution
trans′ {x} p q = subst (x ≡_) q p
