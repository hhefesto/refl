-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
-- @statement
example : ∀ (x y : ℕ) → suc x + y ≡ x + suc y
-- @template
-- The complete worked proof is below.
-- @solution
example x zero = refl
example x (suc y) = cong suc (example x y)
