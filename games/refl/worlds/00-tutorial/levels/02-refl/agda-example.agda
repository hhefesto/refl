-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
-- @statement
example : 3 + 1 ≡ 4
-- @template
-- The complete worked proof is below.
-- @solution
example = refl
