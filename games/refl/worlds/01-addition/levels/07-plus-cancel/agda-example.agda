-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
wrap : ℕ → ℕ → ℕ
wrap zero x = x
wrap (suc n) x = suc (wrap n x)
un : ℕ → ℕ
un zero = zero
un (suc n) = n

example : ∀ n x y → wrap n x ≡ wrap n y → x ≡ y
-- @template
-- The complete worked proof is below.
-- @solution
example zero x y h = h
example (suc n) x y h = example n x y (cong un h)
