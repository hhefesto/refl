-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.RewriteChain where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
two-three : ∀ (x y : ℕ) → x ≡ 2 → y ≡ 3 → x + y ≡ 5
-- @template
two-three x y p q = ?
-- @solution
two-three x y p q rewrite p | q = refl
