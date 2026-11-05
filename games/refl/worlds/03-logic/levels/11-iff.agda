-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.Iff where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.World.Logic using (×-comm)
-- @statement
×-swap-⇔ : ∀ {A B : Set} → (A × B) ⇔ (B × A)
-- @template
×-swap-⇔ = ?
-- @solution
×-swap-⇔ = mk⇔ ×-comm ×-comm
