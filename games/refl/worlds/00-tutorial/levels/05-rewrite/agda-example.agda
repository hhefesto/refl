-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
-- @statement
example : ∀ (n : ℕ) → n ≡ 4 → n + 1 ≡ 5
-- @template
-- The complete worked proof is below.
-- @solution
example n h rewrite h = refl
