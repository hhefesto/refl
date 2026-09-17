-- @prelude
{-# OPTIONS --safe --without-K #-}
module Tutorial.Cong where

open import Refl.Nat
open import Refl.Eq
-- @statement
suc-cong : ∀ {x y : ℕ} → x ≡ y → suc x ≡ suc y
-- @template
suc-cong h = ?
-- @solution
suc-cong h = cong suc h
