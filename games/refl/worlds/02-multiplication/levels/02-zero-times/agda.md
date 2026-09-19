---
title: "zero-*"
learning_goals:
  - "Induction on the right argument of `*`."
hints:
  - text: "Case split on `x`. The step goal is `zero * x + zero ≡ zero`, and `_+ zero` computes away."
  - text: "`zero-* zero = refl`; `zero-* (suc x) = zero-* x`."
    hidden: true
example_explanation: |-
  1. Unfold the recursive accumulator at zero.
  2. In the successor case, adding zero disappears by definition.
  3. The smaller proof is exactly the goal. Look for the same disappearance in the exercise's sum or product.
---
The mirror of `x * zero ≡ zero`, by induction.

<!-- @conclusion -->
Compare with `sumTo-zero`: same proof, because a product is a repeated sum.
