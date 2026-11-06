---
id: multiplication
title: "Multiplication World"
dependencies: [addition]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
Multiplication and powers, defined by recursion on the second argument, written here in Agda
notation (Lean and Bend spell the same definitions their own way):

```agda
m * zero  = zero
m * suc n = m * n + m

m ^ zero  = 1
m ^ suc n = m ^ n * m
```

The proofs are the same shape as Addition World's, but now every inductive step rearranges a sum,
so you will lean on associativity, commutativity and `+-right-comm` from your inventory, and on
small functions like `(_+ x)` to apply an equation inside a larger term.

The reading level at the end pulls a constant factor out of a finite sum.
