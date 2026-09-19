-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
-- @statement
example : ∀ (x y z : ℕ) → x * (y + z) + x ≡ x * y + (x * z + x)
-- @template
-- The complete worked proof is below.
-- @solution
example x y zero = cong (x * y +_) (sym (zero-+ x))
example x y (suc z) = trans (cong (_+ x) (example x y z))
  (+-assoc (x * y) (x * z + x) x)
