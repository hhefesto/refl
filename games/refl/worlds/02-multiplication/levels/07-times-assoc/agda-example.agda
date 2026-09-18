-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
open import Refl.World.Multiplication using (*-distribˡ-+)

example : ∀ a b c → a * b + a * c ≡ a * (b + c)
-- @template
-- The complete worked proof is below.
-- @solution
example a b c = sym (*-distribˡ-+ a b c)
