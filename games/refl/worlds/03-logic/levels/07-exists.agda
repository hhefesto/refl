-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.Exists where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
witness : ∃ (λ n → n + 1 ≡ 3)
-- @template
witness = ?
-- @solution
witness = 2 , refl
