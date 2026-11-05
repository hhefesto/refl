-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
example : ∀ a b → a ≡ 1 → b ≡ 4 → a + b ≡ 5
-- @template
-- The complete worked proof is below.
-- @solution
example a b p q rewrite p | q = refl
