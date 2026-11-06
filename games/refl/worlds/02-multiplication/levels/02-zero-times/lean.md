---
title: "zero_mul"
learning_goals:
  - "Induction on the right argument of `*`."
hints:
  - text: "`induction x with`. The `zero` case is `rfl`. What does `0 * succ x` compute to?"
  - text: "It computes to `0 * x + 0`, and `+ 0` computes away, so what's left is `ih`, as far as `exact` is concerned."
  - text: "`| zero => rfl`, and `| succ x ih => exact ih`."
example_explanation: |-
  1. Unfold the recursive definition at zero.
  2. In the successor case, adding zero disappears by computation.
  3. The hypothesis is exactly the goal. Look for the same disappearance in the exercise's product.
---
`x * 0 = 0` holds by computation. This level is its mirror image, `0 * x = 0`, and it doesn't: the `x`
is on the right, where multiplication looks, so `0 * x` is stuck for the same reason `0 + x` was.

So this needs induction, and you know how that goes. Use `induction x with` and a case for each
constructor.

Don't reach for `congrArg succ` out of habit, though. So far every inductive step had a `succ` on the
outside of both sides, because addition puts one there. Multiplication doesn't. Unfold `0 * succ x`
by the second clause of `mul` on paper, and see what you get. In the end the inductive step may need
less than you expect.

<!-- @conclusion -->
Compare with `sumTo_zero` from Addition World: it's the same proof, because a product is a repeated sum.
