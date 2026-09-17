-- @prelude
{-# OPTIONS --safe --without-K #-}
module Addition.PlusCancel where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Addition using (suc-injective)
-- @statement
+-cancelʳ : ∀ (x y z : ℕ) → x + z ≡ y + z → x ≡ y
-- @template
+-cancelʳ x y z h = ?
-- @solution
+-cancelʳ x y zero h = h
+-cancelʳ x y (suc z) h = +-cancelʳ x y z (suc-injective h)
