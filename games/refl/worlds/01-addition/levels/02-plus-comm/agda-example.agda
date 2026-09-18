-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (suc-+)
-- @statement
example : ∀ (x : ℕ) → x + 1 ≡ 1 + x
-- @template
-- The complete worked proof is below.
-- @solution
example x = sym (trans (suc-+ zero x) (cong suc (zero-+ x)))
