-- @prelude
{-# OPTIONS --safe --without-K #-}
module Multiplication.TimesAssoc where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (*-distribˡ-+)
-- @statement
*-assoc : ∀ (x y z : ℕ) → (x * y) * z ≡ x * (y * z)
-- @template
*-assoc x y z = ?
-- @solution
*-assoc x y zero = refl
*-assoc x y (suc z) = trans (cong (_+ x * y) (*-assoc x y z)) (sym (*-distribˡ-+ x (y * z) y))
