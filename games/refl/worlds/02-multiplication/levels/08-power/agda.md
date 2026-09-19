---
title: "x ^ 2"
learning_goals:
  - "Unfolding `_^_` two steps."
  - "A `cong` with a section on the *left* factor: `(_* x)`."
hints:
  - text: "Normalise `x ^ 2`: it is `1 * x * x`, that is `(1 * x) * x`. Only the inner `1 * x` needs a lemma."
  - text: "`cong (_* x) (one-* x)`."
    hidden: true
example_explanation: |-
  1. Unfold `_^_`: `x ^ 1` is `x ^ suc zero`, which computes to `x ^ zero * x`, then to `1 * x`.
  2. `1 * x` is stuck (`_*_` recurses on its second argument), and `one-* x` is exactly that equation.
  For the exercise, `x ^ 2` unfolds one step further, to `(1 * x) * x`; rewrite the inner `1 * x` with `one-*` under `cong (λ n → n * x)`.
---
Powers are defined like products: `m ^ suc n = m ^ n * m` and `m ^ zero =
1`. Normalise first, then find the one place that does not compute.

<!-- @conclusion -->
**Multiplication World** is nearly done. The reading level connects
distributivity to sums.
