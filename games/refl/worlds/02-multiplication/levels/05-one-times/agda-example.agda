-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (*-one; *-comm; one-*; suc-*; zero-*)
-- @statement
example : ∀ (x : ℕ) → 2 * x ≡ x + x
-- @template
-- The complete worked proof is below.
-- @solution
example x = trans (suc-* 1 x) (cong (λ n → n + x) (one-* x))
