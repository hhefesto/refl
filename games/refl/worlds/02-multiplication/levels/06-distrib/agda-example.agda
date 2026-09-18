-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
open import Refl.World.Addition using (+-assoc)

example : ∀ a b c → suc ((a + b) + c) ≡ suc (a + (b + c))
-- @template
-- The complete worked proof is below.
-- @solution
example a b c = cong suc (+-assoc a b c)
