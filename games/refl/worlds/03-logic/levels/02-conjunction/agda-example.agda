-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
example : ∀ {A B C : Set} → (A × B) × C → A × (B × C)
-- @template
-- The complete worked proof is below.
-- @solution
example ((a , b) , c) = a , (b , c)
