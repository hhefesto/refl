-- @prelude
{-# OPTIONS --safe --without-K #-}
module Addition.RightComm where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Addition using (+-comm; +-assoc)
open ≡-Reasoning
-- @statement
+-right-comm : ∀ (x y z : ℕ) → (x + y) + z ≡ (x + z) + y
-- @template
+-right-comm x y z =
  begin
    (x + y) + z ≡⟨ ? ⟩
    x + (y + z) ≡⟨ ? ⟩
    x + (z + y) ≡⟨ ? ⟩
    (x + z) + y ∎
-- @solution
+-right-comm x y z =
  begin
    (x + y) + z ≡⟨ +-assoc x y z ⟩
    x + (y + z) ≡⟨ cong (x +_) (+-comm y z) ⟩
    x + (z + y) ≡⟨ sym (+-assoc x z y) ⟩
    (x + z) + y ∎
