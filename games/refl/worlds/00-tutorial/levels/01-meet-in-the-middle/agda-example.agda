-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where

open import Refl.Nat
open import Refl.Eq
open ≡-Reasoning
-- @statement
example : 3 + 1 ≡ 4
-- @template
-- The complete worked proof is below.
-- @solution
example =
  begin
    3 + 1  ≡⟨⟩
    suc 3  ≡⟨⟩
    4      ∎
