-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.Negation where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
contraposition : ∀ {A B : Set} → (A → B) → ¬ B → ¬ A
-- @template
contraposition f = ?
-- @solution
contraposition f ¬b a = ¬b (f a)
