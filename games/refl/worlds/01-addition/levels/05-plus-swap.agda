-- @prelude
{-# OPTIONS --safe --without-K #-}
module Addition.PlusSwap where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Addition using (+-comm; +-assoc)
open ≡-Reasoning
-- @statement
+-swap : ∀ (x y z : ℕ) → x + (y + z) ≡ y + (x + z)
-- @template
+-swap x y z = ?
-- @solution
+-swap x y z =
  begin
    x + (y + z) ≡⟨ sym (+-assoc x y z) ⟩
    (x + y) + z ≡⟨ cong (_+ z) (+-comm x y) ⟩
    (y + x) + z ≡⟨ +-assoc y x z ⟩
    y + (x + z) ∎
