-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
example : ∀ {a b : ℕ} → a ≡ b → suc a ≡ suc b
-- @template
-- The complete worked proof is below.
-- @solution
example = λ { refl → refl }
