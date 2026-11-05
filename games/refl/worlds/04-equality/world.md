---
id: equality
title: "Equality World"
dependencies: [addition, logic]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
`_≡_` is just a data type with one constructor, and everything you have used about it
— `sym`, `trans`, `cong`, `subst`, `rewrite` — comes from pattern matching on `refl`.
This world opens that box.

It starts by matching on `refl` by hand, then adds the tools built on that: rewrite
chains, pattern-matching lambdas, `with` abstraction, `with … in eq` (and the older
`inspect` idiom you will meet in older code), `subst`, and the principle behind them
all, J. It finishes with Hedberg's theorem: a type with decidable equality has unique
identity proofs, no axiom K needed.

The recurring example is the Kronecker delta, which is `1` when its indices are equal
and `0` otherwise:

```agda
δ i j with i ≟ j
... | yes _ = 1
... | no  _ = 0
```

Its lemmas (`δ-diag`, `δ-sym`) are proved exactly the way this world teaches.
