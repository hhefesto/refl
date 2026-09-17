-- @prelude
{-# OPTIONS --safe --without-K #-}
module Addition.SucInjective where

open import Refl.Nat
open import Refl.Eq
-- @statement
pred : ℕ → ℕ
pred zero = zero
pred (suc n) = n

suc-injective : ∀ {x y : ℕ} → suc x ≡ suc y → x ≡ y
-- @template
suc-injective h = ?
-- @solution
suc-injective h = cong pred h
