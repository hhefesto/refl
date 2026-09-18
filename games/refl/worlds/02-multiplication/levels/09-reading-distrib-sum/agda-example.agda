-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open import Refl.World.Multiplication using (*-distribˡ-+)
-- @statement
sumTo : (ℕ → ℕ) → ℕ → ℕ
sumTo f zero = zero
sumTo f (suc n) = sumTo f n + f n

interchange : ∀ (a b c d : ℕ) → (a + b) + (c + d) ≡ (a + c) + (b + d)
interchange a b c d = trans (+-assoc a b (c + d)) (trans (cong (λ n → a + n) (+-swap b c d)) (sym (+-assoc a c (b + d))))

sum-split : ∀ (f g : ℕ → ℕ) (n : ℕ) → sumTo (λ i → f i + g i) n ≡ sumTo f n + sumTo g n
-- @template
-- The complete worked proof is below.
-- @solution
sum-split f g zero = refl
sum-split f g (suc n) = trans (cong (λ s → s + (f n + g n)) (sum-split f g n)) (interchange (sumTo f n) (sumTo g n) (f n) (g n))
