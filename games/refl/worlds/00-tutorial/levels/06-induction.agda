-- @prelude
{-# OPTIONS --safe --without-K #-}
module Tutorial.Induction where

open import Refl.Nat
open import Refl.Eq
-- @statement
zero-+ : ∀ (x : ℕ) → zero + x ≡ x
-- @template
zero-+ x = ?
-- @solution
zero-+ zero = refl
zero-+ (suc x) = cong suc (zero-+ x)
