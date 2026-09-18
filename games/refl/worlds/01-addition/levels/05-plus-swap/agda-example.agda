-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Addition using (+-comm; +-assoc)
open ≡-Reasoning
-- @statement
example : ∀ (x y z : ℕ) → (x + y) + z ≡ (y + x) + z
-- @template
-- The complete worked proof is below.
-- @solution
example x y z = cong (λ n → n + z) (+-comm x y)
