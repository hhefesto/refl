---
example_explanation: |-
  1. Split both decisions, producing four cases.
  2. Agreeing decisions produce identical numbers.
  3. Disagreeing decisions contain a witness and its refutation. The exercise's decisions have opposite equality orientations, so reverse a witness before refuting it.
hints:
- hidden: false
  text: Two decisions about the same equality must agree, even when their endpoints
    are reversed.
- hidden: true
  text: Abstract both comparisons. The mixed cases contain an equality and a refutation
    in the opposite direction.
- hidden: true
  text: Use `with i ≟ j | j ≟ i`; in a mixed branch eliminate a contradiction built
    using `sym`.
learning_goals:
- '`with` on two scrutinees gives a grid of cases.'
- Contradictory cases are closed with `⊥-elim` and `sym`.
title: 'Reading: δ is symmetric (Matrix.lagda)'
---
Two decisions about the same equality must agree, even when their endpoints are reversed.

`Matrix.lagda:305`:

```agda
diag-sym w i j with i ≟ j
```

Here is its core: the Kronecker delta is symmetric. Abstract both
decisions at once (`with i ≟ j | j ≟ i`) and handle the four cases.


<!-- @conclusion -->

**Equality World complete.** You can now read every `with`, `rewrite`,
`inspect`, `subst₂` and `Decidable⇒UIP` in the three target
repositories. Order World is next: `_≤_` as data, and the Boolean
reflection idiom (`T`, `≤ᵇ⇒≤`) that `Decoding.agda` is built on.
