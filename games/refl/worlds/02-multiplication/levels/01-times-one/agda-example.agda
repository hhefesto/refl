-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
open import Refl.World.Tutorial using (zero-+)

example : ∀ n → (zero + n) + 1 ≡ n + 1
-- @template
-- The complete worked proof is below.
-- @solution
example n = cong suc (zero-+ n)
