-- @prelude
{-# OPTIONS --safe --without-K #-}
module Multiplication.ReadingDistribSum where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (*-distribˡ-+)
-- @statement
sumTo : (ℕ → ℕ) → ℕ → ℕ
sumTo f zero = zero
sumTo f (suc n) = sumTo f n + f n

sum-factor : ∀ (c : ℕ) (f : ℕ → ℕ) (n : ℕ) → sumTo (λ i → c * f i) n ≡ c * sumTo f n
-- @template
sum-factor c f n = ?
-- @solution
sum-factor c f zero = refl
sum-factor c f (suc n) = trans (cong (_+ c * f n) (sum-factor c f n)) (sym (*-distribˡ-+ c (sumTo f n) (f n)))
