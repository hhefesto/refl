-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
open import Refl.World.Logic using (_≟_)
open ≡-Reasoning
-- @statement
example : ∀ {A : Set} {x y : A} (p : x ≡ y) → trans p refl ≡ p
-- @template
-- The complete worked proof is below.
-- @solution
example refl = refl
