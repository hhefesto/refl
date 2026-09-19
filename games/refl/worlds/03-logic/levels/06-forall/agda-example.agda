-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
example : ∀ {P Q : ℕ → Set} → (∀ n → P n) → (∀ n → Q n) → ∀ n → P n × Q n
-- @template
-- The complete worked proof is below.
-- @solution
example p q n = p n , q n
