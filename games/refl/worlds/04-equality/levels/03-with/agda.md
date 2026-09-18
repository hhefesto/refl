---
example_explanation: |-
  1. Abstract the decision with `with`.
  2. In the `yes` branch the function computes.
  3. In the `no` branch its refutation contradicts the supplied witness. The exercise supplies a reflexive equality as that witness.
hints:
- hidden: false
  text: Matching on a computed decision lets a stuck definition reduce.
- hidden: true
  text: Repeat the same decision as the definition of δ. A negative decision contradicts
    reflexivity.
- hidden: true
  text: Start `δ-diag i with i ≟ i` and add `yes` and `no` branches.
learning_goals:
- '`with e` adds the value of `e` as a new column to match on.'
- A function defined by `with` computes only once the scrutinee is known; lemmas about
  it repeat the same `with`.
title: with abstraction
---
Matching on a computed decision lets a stuck definition reduce.

Spectra2's Kronecker delta:

```agda
δ i j with i ≟ j
... | yes _ = 1
... | no  _ = 0
```

`with` matches on an *expression*, not a variable: it abstracts `i ≟ j`
out of the goal and lets you case split on the result. The dots `...` mean
"the same left-hand side as above".

Prove `δ i i ≡ 1`. Since `δ` computes only when `i ≟ j` does, your proof
must `with i ≟ i` as well, and refute the `no` case.


<!-- @conclusion -->

This is the most important idiom in the target code: `Matrix.lagda:305`
(`diag-sym w i j with i ≟ j`), `Decoding.agda`, `AD/Reverse.agda`
(`composeD g f x with f x`). `rewrite` is a `with` on an equation.
