-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (+-comm; +-assoc; +-right-comm; +-swap)
open ≡-Reasoning
-- @statement

example : ∀ a b c → suc ((a + b) + c) ≡ suc (a + (b + c))
-- @template
-- The complete worked proof is below.
-- @solution
example a b c = cong suc (+-assoc a b c)
