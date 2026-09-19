-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Addition using (+-comm; +-assoc)
open ≡-Reasoning
-- @statement
open ≡-Reasoning

example : ∀ {a b c : ℕ} → a ≡ b → b ≡ c → suc a ≡ suc c
-- @template
-- The complete worked proof is below.
-- @solution
example {a} {b} {c} p q =
  begin
    suc a ≡⟨ cong suc p ⟩
    suc b ≡⟨ cong suc q ⟩
    suc c ∎
