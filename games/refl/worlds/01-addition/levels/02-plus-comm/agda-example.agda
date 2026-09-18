-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
example : ∀ {a b c : ℕ} → a ≡ b → c ≡ b → a ≡ c
-- @template
-- The complete worked proof is below.
-- @solution
example p q = trans p (sym q)
