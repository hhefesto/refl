---
id: equality
title: "Equality World"
dependencies: [addition, logic]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
Equality is just a type with one constructor, and everything you have used about it comes from that.
This world opens the box.

It starts by using an equation directly, then adds the tools built on that: rewrite chains, anonymous
functions, branching on a decision, remembering what a test said, carrying a proof across an equation,
and the principle behind them all, J. It finishes with Hedberg's theorem: a type with decidable equality
has unique identity proofs. This is where the three languages part ways, as you'll see.

The recurring example is the Kronecker delta, which is `1` when its indices are equal and `0` otherwise.
Written in Agda notation (each language's lessons show its own):

```agda
δ i j with i ≟ j
... | yes _ = 1
... | no  _ = 0
```
