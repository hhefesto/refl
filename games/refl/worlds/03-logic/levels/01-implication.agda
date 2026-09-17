-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.Implication where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
modus-ponens : ∀ {A B : Set} → A → (A → B) → B
-- @template
modus-ponens = ?
-- @solution
modus-ponens a f = f a
