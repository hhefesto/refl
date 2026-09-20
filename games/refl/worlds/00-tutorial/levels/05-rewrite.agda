-- @prelude
{-# OPTIONS --safe --without-K #-}
module Tutorial.Rewrite where

open import Refl.Nat
open import Refl.Eq
-- @statement
use-h : ∀ (x : ℕ) → x ≡ 3 → x + 2 ≡ 5
-- @template
use-h x h = ?
-- @solution
use-h x h rewrite h = refl
