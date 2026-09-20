-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
-- @statement
example : ∀ (n : ℕ) → n + 0 ≡ n
-- @template
-- The complete worked proof is below.
-- @solution
example n = refl
