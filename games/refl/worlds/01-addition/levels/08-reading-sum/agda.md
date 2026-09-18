---
example_explanation: |-
  1. Unfold the recursive accumulator at zero.
  2. In the successor case, adding zero disappears by definition.
  3. The smaller proof is exactly the goal. Look for the same disappearance in the exercise's sum or product.
hints:
- hidden: false
  text: A finite sum is a recursive fold, so its laws follow induction on its length.
- hidden: true
  text: Split `n`. The new summand is zero, which disappears under the definition
    of addition.
- hidden: true
  text: Write `sumTo-zero zero = …` and `sumTo-zero (suc n) = …`; compare the step
    goal with the recursive hypothesis.
learning_goals:
- A higher-order function `(ℕ → ℕ) → ℕ → ℕ` defined by recursion.
- Lemmas about sums are proved by the same induction as lemmas about `+`.
title: 'Reading: a finite sum'
---
A finite sum is a recursive fold, so its laws follow induction on its length.

Spectra2 (`Scalar.lagda`) spends its first hundred lines proving facts
about finite sums that the standard library lacks: `sum-++`,
`sum-updateAt-+`, `sum-neg`. They all look like this level.

`sumTo f n` is `f 0 + f 1 + … + f (n - 1)`:

```agda
sumTo f zero    = zero
sumTo f (suc n) = sumTo f n + f n
```

Prove that the sum of zeros is zero.


<!-- @conclusion -->

A sum is a fold; a lemma about a sum is an induction on its length. When
you read `sum-remove` or `∑-comm` in `Matrix.lagda` later, look for exactly
this shape.

**Addition World complete.**
