-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (one-*)
-- @statement
example : ∀ (x : ℕ) → x ^ 1 ≡ x
-- @template
-- The complete worked proof is below.
-- @solution
example x = one-* x
