-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
example : Dec (2 ≡ 3)
-- @template
-- The complete worked proof is below.
-- @solution
example = no (λ ())
