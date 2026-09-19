-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.World.Logic using (×-comm)
-- @statement
example : ∀ {A : Set} → A ⇔ (A × ⊤)
-- @template
-- The complete worked proof is below.
-- @solution
example = mk⇔ (λ a → a , tt) proj₁
