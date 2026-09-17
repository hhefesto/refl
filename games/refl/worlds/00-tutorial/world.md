---
id: tutorial
title: "Tutorial World"
dependencies: []
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
Eight levels to learn how the game works: holes, goals, `refl`, and the four
moves you will use forever — **Goal**, **Give**, **Refine**, **Case split**.

The world uses the game's own natural numbers:

```agda
data ℕ : Set where
  zero : ℕ
  suc  : ℕ → ℕ

_+_ : ℕ → ℕ → ℕ
m + zero  = m
m + suc n = suc (m + n)
```

Two things to notice already. Addition recurses on its **second** argument, so
`m + zero` and `m + suc n` compute but `zero + m` does not. And there is no
`=` sign for propositions: equality `_≡_` is a *type* whose only constructor is
`refl : x ≡ x`. A proof of `2 + 2 ≡ 4` is a program of that type.
