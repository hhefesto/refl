-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
-- @statement
example : ∀ (x y z : ℕ) → x + (y + z) ≡ (x + y) + z
-- @template
-- The complete worked proof is below.
-- @solution
example x y zero = refl
example x y (suc z) = cong suc (example x y z)
