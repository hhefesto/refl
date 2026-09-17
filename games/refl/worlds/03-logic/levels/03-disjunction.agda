-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.Disjunction where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
⊎-comm : ∀ {A B : Set} → A ⊎ B → B ⊎ A
-- @template
⊎-comm s = ?
-- @solution
⊎-comm (inj₁ a) = inj₂ a
⊎-comm (inj₂ b) = inj₁ b
