-- @prelude
{-# OPTIONS --safe --without-K #-}
module Multiplication.OneTimes where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (*-one; *-comm)
-- @statement
one-* : ∀ (x : ℕ) → 1 * x ≡ x
-- @template
one-* x = ?
-- @solution
one-* x = trans (*-comm 1 x) (*-one x)
