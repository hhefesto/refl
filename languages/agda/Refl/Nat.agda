{-# OPTIONS --safe --without-K #-}
-- The game's own natural numbers. Deliberately not the standard library's,
-- so that every lemma about them has to be proved in a level (NNG4's MyNat).
-- BUILTIN NATURAL only lets you write numerals like 3 for suc (suc (suc zero)).
module Refl.Nat where

data ℕ : Set where
  zero : ℕ
  suc  : ℕ → ℕ

{-# BUILTIN NATURAL ℕ #-}

infixl 6 _+_
infixl 7 _*_
infixr 8 _^_

-- Recursion on the SECOND argument, so `m + zero` and `m + suc n` compute.
_+_ : ℕ → ℕ → ℕ
m + zero  = m
m + suc n = suc (m + n)

_*_ : ℕ → ℕ → ℕ
m * zero  = zero
m * suc n = m * n + m

_^_ : ℕ → ℕ → ℕ
m ^ zero  = 1
m ^ suc n = m ^ n * m
