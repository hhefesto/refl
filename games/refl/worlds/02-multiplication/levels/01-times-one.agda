-- @prelude
{-# OPTIONS --safe --without-K #-}
module Multiplication.TimesOne where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
-- @statement
*-one : ∀ (x : ℕ) → x * 1 ≡ x
-- @template
*-one x = ?
-- @solution
*-one x = zero-+ x
