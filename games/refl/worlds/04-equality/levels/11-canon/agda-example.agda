-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
open import Refl.World.Equality using (trans-symˡ)
-- @statement
pick : ∀ {x y : ℕ} → x ≡ y → x ≡ y
pick p = p

example : ∀ {x y : ℕ} (p : x ≡ y) → trans (sym (pick refl)) (pick p) ≡ p
-- @template
-- The complete worked proof is below.
-- @solution
example refl = trans-symˡ (pick refl)
