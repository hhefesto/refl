-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (zero-*; suc-*)
-- @statement
example : ∀ (x : ℕ) → zero * x ≡ x * zero
-- @template
-- The complete worked proof is below.
-- @solution
example x = zero-* x
