---
title: "mul_assoc"
learning_goals:
  - "Associativity of `*` needs distributivity in the step."
hints:
  - text: "`induction z with`. After `rw [mul_succ, mul_succ]`, the goal is `x * y * z + x * y = x * (y * z + y)`. On the right, a product with a sum inside: which lemma opens that up?"
  - text: "`mul_add` gives `x * y * z + x * y = x * (y * z) + x * y`. Now both sides have the same shape, and `ih` closes it."
  - text: "`| zero => rfl`, and `| succ z ih => rw [mul_succ, mul_succ, mul_add, ih]`."
example_explanation: |-
  1. The left side is an expanded product.
  2. `mul_add` points from product to sum.
  3. Reverse it with `Eq.symm`. In the exercise use the lemma as it stands, after unfolding.
---
`(x * y) * z = x * (y * z)`, the last of the semiring laws for `MyNat`. As with `add_assoc`, `z` is the variable that
lets both sides compute.

The difference from `add_assoc` shows up in the inductive step. There, unfolding gave a `succ` on both sides, and the
hypothesis applied right away. Here, read the **Goal** after unfolding: the left side is a sum, but the right side is a
product *of* a sum. You can't use `ih` until those two have the same shape, and the lemma you proved in the last level does
that.

So the plan is: unfold, distribute, use the hypothesis. Add one rewrite at a time, and read the goal in between.

<!-- @conclusion -->
With `add_comm`, `add_assoc`, `mul_comm`, `mul_assoc`, `mul_add`, `zero_add`, `zero_mul` and `one_mul` you've shown that
`MyNat` is a **commutative semiring**.
