-- @prelude
{-# OPTIONS --safe --without-K #-}
module Addition.PlusAssoc where

open import Refl.Nat
open import Refl.Eq
-- @statement
+-assoc : ∀ (x y z : ℕ) → (x + y) + z ≡ x + (y + z)
-- @template
+-assoc x y z = ?
-- @solution
+-assoc x y zero = refl
+-assoc x y (suc z) = cong suc (+-assoc x y z)
