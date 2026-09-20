-- @prelude
{-# OPTIONS --safe --without-K #-}
module Tutorial.Refine where

open import Refl.Nat
open import Refl.Eq
-- @statement
three-steps : ∀ (x : ℕ) → (x + 2) + 1 ≡ x + 3
-- @template
three-steps x = ?
-- @solution
three-steps x = refl
