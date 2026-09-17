-- @prelude
{-# OPTIONS --safe --without-K #-}
module Multiplication.TimesComm where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (zero-*; suc-*)
-- @statement
*-comm : ∀ (x y : ℕ) → x * y ≡ y * x
-- @template
*-comm x y = ?
-- @solution
*-comm x zero = sym (zero-* x)
*-comm x (suc y) = trans (cong (_+ x) (*-comm x y)) (sym (suc-* y x))
