-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
example : ∃ (λ n → n + 2 ≡ 6)
-- @template
-- The complete worked proof is below.
-- @solution
example = 4 , refl
