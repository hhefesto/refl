-- @prelude
{-# OPTIONS --safe --without-K #-}
module Tutorial.SymTrans where

open import Refl.Nat
open import Refl.Eq
-- @statement
flip-chain : ∀ {x y z : ℕ} → y ≡ x → y ≡ z → x ≡ z
-- @template
flip-chain p q = ?
-- @solution
flip-chain p q = trans (sym p) q
