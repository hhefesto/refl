---
title: "zero_mul"
learning_goals:
  - "Induction on the right argument of `mul`."
hints:
  - text: "`match x:`. Then read the **Goal** in the `1n+p` case."
  - text: "It says `{Refl.mul(0n, p) == 0n : Nat}`. Multiplying added a `0n`, which computed away, so what's left is this very statement for the smaller `p`."
  - text: "`case 0n:` is `{==}`, and `case 1n+p:` is `zero_mul(p)`."
example_explanation: |-
  1. Unfold the recursive definition at zero.
  2. In the successor case, adding zero disappears by computation.
  3. The smaller proof is exactly the goal. Look for the same disappearance in the exercise's product.
---
`Refl.mul(x, 0n)` computes to `0n`. This level is its mirror image, `Refl.mul(0n, x) == 0n`, and it doesn't compute: the `x` is on the right, where multiplication looks, so it's stuck for the same reason `Refl.add(0n, x)` was.

So this needs induction, and you know how that goes: `match x:`, a case for each constructor, and read each **Goal**.

Don't reach for `Equal.cong` out of habit, though. So far every inductive step had a `1n+` on the outside of both sides, because addition puts one there. Multiplication doesn't. Read the goal in the `1n+p` case and see what's left. The inductive step may need less than you expect.

<!-- @conclusion -->
Compare with `sum_zeros` from Addition World: it's the same proof, because a product is a repeated sum.
