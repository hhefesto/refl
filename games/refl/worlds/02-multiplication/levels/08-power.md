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
      bend2: "Multiplication.pow_two"
      agda: "^-two"
      lean: "pow_two"
hints:
  - text: "Select the hole and press **Goal**. It says `1 * x * x ≡ x * x`, which parses as `(1 * x) * x`. Only one part of the left side isn't already on the right."
  - text: "`one-* x` turns `1 * x` into `x`. Use it under the section `(_* x)`: `^-two x = cong (_* x) (one-* x)`."
---
Powers are defined the way products are, again by looking at the second argument:

```agda
m ^ zero  = 1
m ^ suc n = m ^ n * m
```

Prove that `x ^ 2` really is `x * x`. There's no induction here, because the `2` is
known and the definition can run. Before you use any lemma, ask for the **Goal** and
see how far it gets.

This is a good habit in general: **normalise first, then find the one place that
doesn't compute**. Most of the term usually takes care of itself, and what's left is
small.

To change one factor of a product and leave the other alone, you need a section again.
Last level's was `(_+ x * y)`; which section would hold the `* x` fixed?

<!-- @conclusion -->
Two steps of `_^_` left only one stuck piece, which `one-*` took care of. The reading
level that closes this world connects distributivity to sums.
