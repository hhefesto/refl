-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
-- @statement
zeros : ℕ → ℕ
zeros zero = zero
zeros (suc n) = zeros n + zero

example : ∀ n → zeros n ≡ zero
-- @template
-- The complete worked proof is below.
-- @solution
example zero = refl
example (suc n) = example n
