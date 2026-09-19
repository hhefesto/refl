---
title: "Reading: a finite sum"
learning_goals:
  - "A higher-order function `(ℕ → ℕ) → ℕ → ℕ` defined by recursion."
  - "Lemmas about sums are proved by the same induction as lemmas about `+`."
hints:
  - text: "Induction on `n`. In the step the goal is `sumTo (λ _ → zero) n + zero ≡ zero`; `_+ zero` computes away, so the induction hypothesis closes it."
  - text: "`sumTo-zero zero = refl` and `sumTo-zero (suc n) = sumTo-zero n`."
    hidden: true
example_explanation: |-
  1. Read the definition: `count (suc n)` unfolds to `count n + 1`, and `_ + 1` computes to `suc _`.
  2. So the goal at `suc n` is `suc (count n) ≡ suc n`: `cong suc` of the recursive call.
  The exercise's `sumTo (λ _ → zero)` unfolds the same way, with `+ zero` computing away instead of `+ 1`.
---
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
