---
id: tutorial
title: "Tutorial World"
dependencies: []
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
Nine levels introduce equality by computation, substitution, induction and
composition of proofs. Each lesson explains the syntax and commands for your
selected language, with clues and a checked example available from the start.

The world uses natural numbers built from zero and successor, and its own
addition, written here in Agda notation (Lean and Bend spell the same
definitions their own way):

```agda
data ℕ : Set where
  zero : ℕ
  suc  : ℕ → ℕ

_+_ : ℕ → ℕ → ℕ
m + zero  = m
m + suc n = suc (m + n)
```

Two things to notice already. Addition recurses on its **second** argument, so
`m + zero` and `m + suc n` compute but `zero + m` does not: adding a known
numeral computes even when the first argument is a variable, while
`zero + m ≡ m` needs a proof by induction. And there is no `=` sign for
propositions: equality `_≡_` is a *type* whose only constructor is
`refl : x ≡ x`. A proof of `2 + 2 ≡ 4` is a program of that type.
