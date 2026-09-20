-- @prelude
{-# OPTIONS --safe --without-K #-}
module Tutorial.Refl where

open import Refl.Nat
open import Refl.Eq
-- @statement
two-plus-two : 2 + 2 ≡ 4
-- @template
two-plus-two = ?
-- @solution
two-plus-two = refl
