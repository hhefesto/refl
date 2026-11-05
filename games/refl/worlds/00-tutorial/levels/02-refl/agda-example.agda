-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
-- @statement
example : 20 + 22 ≡ 42
-- @template
-- The complete worked proof is below.
-- @solution
example = refl
