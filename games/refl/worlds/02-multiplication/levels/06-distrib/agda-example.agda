-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (*-distribˡ-+)
-- @statement
example : ∀ (x y z : ℕ) → x * (y + z) + x ≡ x * y + (x * z + x)
-- @template
-- The complete worked proof is below.
-- @solution
example x y z = trans (cong (λ n → n + x) (*-distribˡ-+ x y z)) (+-assoc (x * y) (x * z) x)
