-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
example : ∀ {A B : Set} → A ⊎ A → A
-- @template
-- The complete worked proof is below.
-- @solution
example (inj₁ a) = a
example (inj₂ a) = a
