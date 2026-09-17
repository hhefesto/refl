{-# OPTIONS --safe --without-K #-}
-- Booleans and the reflection between Bool-valued tests and propositions
-- (the `T`/`≤ᵇ⇒≤` idiom of formalTransformer's Decoding.agda).
module Refl.Bool where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic

data Bool : Set where
  true  : Bool
  false : Bool

not : Bool → Bool
not true  = false
not false = true

infixr 6 _∧_
infixr 5 _∨_

_∧_ : Bool → Bool → Bool
true  ∧ b = b
false ∧ _ = false

_∨_ : Bool → Bool → Bool
true  ∨ _ = true
false ∨ b = b

if_then_else_ : ∀ {A : Set} → Bool → A → A → A
if true  then t else _ = t
if false then _ else e = e

-- A boolean as a proposition: true is trivially provable, false is absurd.
T : Bool → Set
T true  = ⊤
T false = ⊥

infix 4 _≡ᵇ_ _≤ᵇ_

_≡ᵇ_ : ℕ → ℕ → Bool
zero  ≡ᵇ zero  = true
zero  ≡ᵇ suc _ = false
suc _ ≡ᵇ zero  = false
suc m ≡ᵇ suc n = m ≡ᵇ n

_≤ᵇ_ : ℕ → ℕ → Bool
zero  ≤ᵇ _     = true
suc _ ≤ᵇ zero  = false
suc m ≤ᵇ suc n = m ≤ᵇ n

≡ᵇ⇒≡ : ∀ (m n : ℕ) → (m ≡ᵇ n) ≡ true → m ≡ n
≡ᵇ⇒≡ zero    zero    _ = refl
≡ᵇ⇒≡ zero    (suc n) ()
≡ᵇ⇒≡ (suc m) zero    ()
≡ᵇ⇒≡ (suc m) (suc n) h = cong suc (≡ᵇ⇒≡ m n h)

≡⇒≡ᵇ : ∀ (m n : ℕ) → m ≡ n → (m ≡ᵇ n) ≡ true
≡⇒≡ᵇ zero    zero    _ = refl
≡⇒≡ᵇ (suc m) (suc n) h = ≡⇒≡ᵇ m n (cong pred h)
  where
    pred : ℕ → ℕ
    pred zero    = zero
    pred (suc k) = k
