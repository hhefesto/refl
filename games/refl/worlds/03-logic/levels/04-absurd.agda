-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.Absurd where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
ex-falso : ∀ {A : Set} → ⊥ → A

trivial : ⊤
-- @template
ex-falso h = ?

trivial = ?
-- @solution
ex-falso ()

trivial = tt
