-- @prelude
{-# OPTIONS --safe --without-K #-}
module Tutorial.Variable where

open import Refl.Nat
open import Refl.Eq
-- @statement
same : ∀ (x : ℕ) → x ≡ x
-- @template
same x = ?
-- @solution
same x = refl
