---
id: multiplication
title: "Multiplication World"
dependencies: [addition]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
Multiplication and powers, defined by recursion on the second argument:

```agda
m * zero  = zero
m * suc n = m * n + m

m ^ zero  = 1
m ^ suc n = m ^ n * m
```

The proofs are the same shape as Addition World's, but now every inductive
step rearranges a sum, so you will lean on `+-assoc`, `+-comm` and
`+-right-comm` from your inventory — and on operator **sections** like
`(_+ x)` and `(x *_)` inside `cong`.

The reading level at the end is the shape of `*-distribˡ-sum` in the
standard library's `Algebra.Properties.Semiring.Sum`, which Spectra2's matrix
algebra is built on.
