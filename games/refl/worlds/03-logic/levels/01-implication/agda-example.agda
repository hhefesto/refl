-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
example : ∀ {A B C : Set} → (A → B) → (B → C) → A → C
-- @template
-- The complete worked proof is below.
-- @solution
example f g a = g (f a)
