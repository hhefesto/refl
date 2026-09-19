-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (*-one; *-comm)
-- @statement
example : ∀ (x : ℕ) → 1 * x + 0 ≡ x
-- @template
-- The complete worked proof is below.
-- @solution
example x = trans (*-comm 1 x) (*-one x)
