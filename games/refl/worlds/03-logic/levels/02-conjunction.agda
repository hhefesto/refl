-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.Conjunction where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
×-comm : ∀ {A B : Set} → A × B → B × A
-- @template
×-comm p = ?
-- @solution
×-comm (a , b) = b , a
