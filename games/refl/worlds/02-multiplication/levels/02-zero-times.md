---
id: zero-times
index: 2
title: "zero-*"
learning_goals:
  - "Induction on the right argument of `*`."
unlocks:
  lemmas:
    - name: "zero-*"
      bend2: "Multiplication.zero_mul"
      agda: "zero-*"
      lean: "zero_mul"
hints:
  - text: "**Case split** on `x`, then read the **Goal** in the `suc` clause."
  - text: "It says `0 * x ≡ 0`. Multiplying added a `+ zero`, which computed away, so what is left is this very statement for the smaller `x`."
  - text: "`zero-* zero = refl`, and `zero-* (suc x) = zero-* x`."
---
`x * zero ≡ zero` holds by computation. This level is its mirror image,
`zero * x ≡ zero`, and it doesn't: the `x` is on the right, where multiplication
looks, so `zero * x` is stuck for the same reason `zero + x` was.

So this needs induction, and you know how that goes: **Case split** on `x`, then
read the **Goal** in each clause.

Don't reach for `cong suc` out of habit, though. So far every inductive step had a
`suc` on the outside of both sides, because addition puts one there. Multiplication
doesn't. Unfold `zero * suc x` by the second clause of `_*_` and see what you get,
or just read the goal. In the end the inductive step may need less than you expect.

<!-- @conclusion -->
Compare with `sumTo-zero` from Addition World: it is the same proof, because a
product is a repeated sum.
