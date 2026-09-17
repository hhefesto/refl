-- @prelude
{-# OPTIONS --safe --without-K #-}
module Multiplication.ZeroTimes where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
-- @statement
zero-* : ∀ (x : ℕ) → zero * x ≡ zero
-- @template
zero-* x = ?
-- @solution
zero-* zero = refl
zero-* (suc x) = zero-* x
