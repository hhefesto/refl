-- @prelude
{-# OPTIONS --safe --without-K #-}
module Addition.SucPlus where

open import Refl.Nat
open import Refl.Eq
-- @statement
suc-+ : ∀ (x y : ℕ) → suc x + y ≡ suc (x + y)
-- @template
suc-+ x y = ?
-- @solution
suc-+ x zero = refl
suc-+ x (suc y) = cong suc (suc-+ x y)
