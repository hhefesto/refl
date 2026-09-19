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
example =
  let same : suc (suc (suc (suc zero))) ≡ suc (suc (suc (suc zero)))
      same = refl
  in same
