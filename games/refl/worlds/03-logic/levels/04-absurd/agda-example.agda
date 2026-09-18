-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
example : ⊥ ⊎ ⊤ → ⊤
-- @template
-- The complete worked proof is below.
-- @solution
example (inj₁ ())
example (inj₂ tt) = tt
