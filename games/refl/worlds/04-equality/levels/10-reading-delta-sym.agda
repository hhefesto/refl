-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.ReadingDeltaSym where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
open import Refl.World.Logic using (_≟_)
open import Refl.World.Equality using (δ)
-- @statement
δ-sym : ∀ (i j : ℕ) → δ i j ≡ δ j i
-- @template
δ-sym i j = ?
-- @solution
δ-sym i j with i ≟ j | j ≟ i
... | yes _ | yes _ = refl
... | yes p | no ¬q = ⊥-elim (¬q (sym p))
... | no ¬p | yes q = ⊥-elim (¬p (sym q))
... | no _  | no _  = refl
