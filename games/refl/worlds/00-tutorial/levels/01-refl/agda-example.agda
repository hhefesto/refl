-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
example : 3 + 1 ≡ 4
-- @template
-- The complete worked proof is below.
-- @solution
example = refl
