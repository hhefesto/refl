---
id: power
index: 8
title: "x ^ 2"
learning_goals:
  - "Unfolding `_^_` two steps."
  - "A `cong` with a section on the *left* factor: `(_* x)`."
unlocks:
  lemmas:
    - name: "^-two"
      agda: "^-two"
      lean: "pow_two"
hints:
  - text: "Normalise `x ^ 2`: it is `1 * x * x`, that is `(1 * x) * x`. Only the inner `1 * x` needs a lemma."
  - text: "`cong (_* x) (one-* x)`."
    hidden: true
---
Powers are defined like products: `m ^ suc n = m ^ n * m` and `m ^ zero =
1`. Normalise first, then find the one place that does not compute.

<!-- @conclusion -->
**Multiplication World** is nearly done. The reading level connects
distributivity to sums.
