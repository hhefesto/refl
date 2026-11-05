-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.ReadingLanguages where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
Pred : Set₁
Pred = ℕ → Set

infixr 6 _∪_
infixr 7 _∩_

_∪_ : Pred → Pred → Pred
(P ∪ Q) n = P n ⊎ Q n

_∩_ : Pred → Pred → Pred
(P ∩ Q) n = P n × Q n

∩⊆∪ : ∀ (P Q : Pred) (n : ℕ) → (P ∩ Q) n → (P ∪ Q) n
-- @template
∩⊆∪ P Q n pq = ?
-- @solution
∩⊆∪ P Q n (p , _) = inj₁ p
