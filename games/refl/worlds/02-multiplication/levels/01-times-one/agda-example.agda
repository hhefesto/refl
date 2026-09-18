-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
-- @statement
example : ∀ (x : ℕ) → x * 2 ≡ x + x
-- @template
-- The complete worked proof is below.
-- @solution
example x = cong (λ n → n + x) (zero-+ x)
