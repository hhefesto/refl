---
example_explanation: |-
  1. Normalize the outer additions into successors.
  2. `zero-+ n` handles the inner expression that is stuck.
  3. Lift that equation through `suc`. In the exercise normalize first, then identify the existing lemma that matches the remaining goal.
hints:
- hidden: false
  text: Expanding a power reveals which part computes and which part needs a law.
- hidden: true
  text: Expand two successor clauses of exponentiation. The inner product `1 * x`
    needs its identity lemma.
- hidden: true
  text: Lift that lemma using `cong (_* x) …`.
learning_goals:
- Unfolding `_^_` two steps.
- 'A `cong` with a section on the *left* factor: `(_* x)`.'
title: x ^ 2
---
Expanding a power reveals which part computes and which part needs a law.

Powers are defined like products: `m ^ suc n = m ^ n * m` and `m ^ zero =
1`. Normalise first, then find the one place that does not compute.


<!-- @conclusion -->

**Multiplication World** is nearly done. The reading level connects
distributivity to sums.
