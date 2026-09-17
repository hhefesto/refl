-- @prelude
{-# OPTIONS --safe --without-K #-}
module Multiplication.Power where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (one-*)
-- @statement
^-two : ∀ (x : ℕ) → x ^ 2 ≡ x * x
-- @template
^-two x = ?
-- @solution
^-two x = cong (_* x) (one-* x)
