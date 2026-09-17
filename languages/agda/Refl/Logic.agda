{-# OPTIONS --safe --without-K #-}
-- Propositions as types: the connectives World 3 is about.
module Refl.Logic where

open import Refl.Eq

-- Truth: one proof, nothing to say.
record ⊤ : Set where
  constructor tt

-- Falsity: no proofs at all.
data ⊥ : Set where

⊥-elim : ∀ {A : Set} → ⊥ → A
⊥-elim ()

-- Negation is implication into ⊥.
infix 3 ¬_
¬_ : Set → Set
¬ A = A → ⊥

-- Conjunction: a pair of proofs.
infixr 2 _×_
infixr 4 _,_
record _×_ (A B : Set) : Set where
  constructor _,_
  field
    proj₁ : A
    proj₂ : B
open _×_ public

-- Disjunction: a tagged proof of one side.
infixr 1 _⊎_
data _⊎_ (A B : Set) : Set where
  inj₁ : A → A ⊎ B
  inj₂ : B → A ⊎ B

-- Dependent pairs and existentials: a witness plus a proof about it.
record Σ (A : Set) (B : A → Set) : Set where
  constructor _,_
  field
    fst : A
    snd : B fst
open Σ public

∃ : ∀ {A : Set} → (A → Set) → Set
∃ {A} B = Σ A B

infix 2 Σ-syntax
Σ-syntax : (A : Set) → (A → Set) → Set
Σ-syntax = Σ
syntax Σ-syntax A (λ x → B) = Σ[ x ∈ A ] B

-- Decidable propositions: a proof or a refutation, as data.
data Dec (A : Set) : Set where
  yes :   A → Dec A
  no  : ¬ A → Dec A

-- Logical equivalence.
infix 1 _⇔_
record _⇔_ (A B : Set) : Set where
  constructor mk⇔
  field
    to   : A → B
    from : B → A
open _⇔_ public

-- Inequality on anything with an equality.
infix 4 _≢_
_≢_ : ∀ {A : Set} → A → A → Set
x ≢ y = ¬ (x ≡ y)
