-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.Impossible where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
zero≢suc : ∀ (n : ℕ) → zero ≢ suc n
-- @template
zero≢suc n = ?
-- @solution
zero≢suc n = λ ()
