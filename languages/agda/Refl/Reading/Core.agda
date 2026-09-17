{-# OPTIONS --safe --without-K #-}
-- Small vocabulary shared by the reading exercises; no exercise solutions.
module Refl.Reading.Core where

open import Level public using (Level; _⊔_; Lift; lift; lower)
  renaming (zero to lzero; suc to lsuc)
open import Data.Nat public using (ℕ; zero; suc; _+_; _*_)
open import Data.Bool public using (Bool; true; false)
open import Data.List.Base public using (List; []; _∷_; _++_; map; foldr; foldl; length; concat)
open import Data.Product public using (Σ; ∃; _×_; _,_; proj₁; proj₂)
open import Data.Sum public using (_⊎_; inj₁; inj₂)
open import Data.Empty public using (⊥; ⊥-elim)
open import Data.Unit public using (⊤; tt)
open import Relation.Nullary.Decidable public using (Dec; yes; no; does)
open import Relation.Binary.PropositionalEquality public
  using (_≡_; refl; sym; trans; cong; cong₂; subst; subst₂; _≗_)
open import Function.Base public using (id; _∘_)

record Iso {a b} (A : Set a) (B : Set b) : Set (a ⊔ b) where
  constructor iso
  field
    to : A → B
    from : B → A
    from-to : ∀ x → from (to x) ≡ x
    to-from : ∀ y → to (from y) ≡ y
