-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
example : ∀ {A : Set} {x y : A} → x ≡ y → (P : A → Set) → P x → P y
-- @template
-- The complete worked proof is below.
-- @solution
example refl P px = px
