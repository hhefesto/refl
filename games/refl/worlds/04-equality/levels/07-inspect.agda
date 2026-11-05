-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.Inspect where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
g : ℕ → ℕ
g n with n ≡ᵇ 0
... | true  = 1
... | false = n

record Reveal_·_is_ {A B : Set} (g : A → B) (x : A) (y : B) : Set where
  constructor [_]
  field eq : g x ≡ y

inspect : ∀ {A B : Set} (g : A → B) (x : A) → Reveal g · x is g x
inspect g x = [ refl ]

g-nonzero : ∀ (n : ℕ) → n ≢ 0 → g n ≡ n
-- @template
g-nonzero n h = ?
-- @solution
g-nonzero n h with n ≡ᵇ 0 | inspect (n ≡ᵇ_) 0
... | true  | [ eq ] = ⊥-elim (h (≡ᵇ⇒≡ n 0 eq))
... | false | _ = refl
