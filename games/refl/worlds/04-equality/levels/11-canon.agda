-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.Canon where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
open import Refl.World.Logic using (_≟_)
open import Refl.World.Equality using (trans-symˡ)
-- @statement
canon : ∀ {x y : ℕ} → x ≡ y → x ≡ y
canon {x} {y} p with x ≟ y
... | yes q = q
... | no ¬q = ⊥-elim (¬q p)

canon-const : ∀ {x y : ℕ} (p q : x ≡ y) → canon p ≡ canon q
canon-const {x} {y} p q with x ≟ y
... | yes _ = refl
... | no ¬q = ⊥-elim (¬q p)

canon-inv : ∀ {x y : ℕ} (p : x ≡ y) → trans (sym (canon refl)) (canon p) ≡ p
-- @template
canon-inv p = ?
-- @solution
canon-inv refl = trans-symˡ (canon refl)
