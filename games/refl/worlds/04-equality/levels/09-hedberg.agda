-- @prelude
{-# OPTIONS --safe --without-K #-}
module Equality.Hedberg where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
open import Refl.World.Logic using (_≟_)
open ≡-Reasoning
-- @statement
canon : ∀ {x y : ℕ} → x ≡ y → x ≡ y
canon {x} {y} p with x ≟ y
... | yes q = q
... | no ¬q = ⊥-elim (¬q p)

canon-const : ∀ {x y : ℕ} (p q : x ≡ y) → canon p ≡ canon q
canon-const {x} {y} p q with x ≟ y
... | yes _ = refl
... | no ¬q = ⊥-elim (¬q p)

trans-symˡ : ∀ {A : Set} {x y : A} (e : x ≡ y) → trans (sym e) e ≡ refl

canon-inv : ∀ {x y : ℕ} (p : x ≡ y) → trans (sym (canon refl)) (canon p) ≡ p

≡-irrelevant : ∀ {x y : ℕ} (p q : x ≡ y) → p ≡ q
-- @template
trans-symˡ e = ?

canon-inv refl = ?

≡-irrelevant p q =
  begin
    p                                    ≡⟨ sym (canon-inv p) ⟩
    trans (sym (canon refl)) (canon p)   ≡⟨ ? ⟩
    trans (sym (canon refl)) (canon q)   ≡⟨ canon-inv q ⟩
    q                                    ∎
-- @solution
trans-symˡ refl = refl

canon-inv refl = trans-symˡ (canon refl)

≡-irrelevant p q =
  begin
    p                                    ≡⟨ sym (canon-inv p) ⟩
    trans (sym (canon refl)) (canon p)   ≡⟨ cong (trans (sym (canon refl))) (canon-const p q) ⟩
    trans (sym (canon refl)) (canon q)   ≡⟨ canon-inv q ⟩
    q                                    ∎
