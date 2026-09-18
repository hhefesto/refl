-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
example : ∀ {A B : Set} {f g : A → B} → (∀ x → f x ≡ g x) → ∀ x → g x ≡ f x
-- @template
-- The complete worked proof is below.
-- @solution
example p x = sym (p x)
