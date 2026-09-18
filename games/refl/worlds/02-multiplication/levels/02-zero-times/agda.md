---
example_explanation: |-
  1. Unfold the recursive accumulator at zero.
  2. In the successor case, adding zero disappears by definition.
  3. The smaller proof is exactly the goal. Look for the same disappearance in the exercise's sum or product.
hints:
- hidden: false
  text: Multiplication is repeated addition; multiplying zero repeatedly stays zero.
- hidden: true
  text: Split the right argument. In the successor case the new summand computes away.
- hidden: true
  text: Write `zero-* (suc x) = …` and compare its type with `zero-* x`.
learning_goals:
- Induction on the right argument of `*`.
title: zero-*
---
Multiplication is repeated addition; multiplying zero repeatedly stays zero.

The mirror of `x * zero ≡ zero`, by induction.


<!-- @conclusion -->

Compare with `sumTo-zero`: same proof, because a product is a repeated sum.
