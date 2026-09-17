-- @prelude
{-# OPTIONS --safe --without-K #-}
module Multiplication.Distrib where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
-- @statement
*-distribˡ-+ : ∀ (x y z : ℕ) → x * (y + z) ≡ x * y + x * z
-- @template
*-distribˡ-+ x y z = ?
-- @solution
*-distribˡ-+ x y zero = refl
*-distribˡ-+ x y (suc z) = trans (cong (_+ x) (*-distribˡ-+ x y z)) (+-assoc (x * y) (x * z) x)
