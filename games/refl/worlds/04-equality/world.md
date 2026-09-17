---
id: equality
title: "Equality World"
dependencies: [addition, logic]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
`_≡_` is just a data type with one constructor, and everything you have used
about it — `sym`, `trans`, `cong`, `subst`, `rewrite` — comes from pattern
matching on `refl`. This world opens that box: J, `with` abstraction, `with …
in eq` (and the older `inspect` idiom you will meet in older code), rewrite
chains, pattern-matching lambdas, and finally Hedberg's theorem: a type with
decidable equality has unique identity proofs, no axiom K needed.

The recurring example is Spectra2's Kronecker delta

```agda
δ i j with i ≟ j
... | yes _ = 1
... | no  _ = 0
```

whose lemmas (`δ-diag`, `δ-sym`) are proved exactly the way this world
teaches.
