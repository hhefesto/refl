-- @prelude
{-# OPTIONS --safe --without-K #-}
module Multiplication.SucTimes where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open ≡-Reasoning
-- @statement
suc-* : ∀ (x y : ℕ) → suc x * y ≡ x * y + y
-- @template
suc-* x y = ?
-- @solution
suc-* x zero = refl
suc-* x (suc y) = cong suc
  (begin
    suc x * y + x ≡⟨ cong (_+ x) (suc-* x y) ⟩
    x * y + y + x ≡⟨ +-right-comm (x * y) y x ⟩
    x * y + x + y ∎)
