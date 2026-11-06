---
title: "succ_mul"
learning_goals:
  - "An inductive step that needs a rearrangement lemma from the inventory."
  - "`n => Refl.add(n, x)` as the function under `Equal.cong`."
hints:
  - text: "`match y:`. The `1n+p` case's goal is `{1n+Refl.add(Refl.mul(1n+x, p), x) == 1n+Refl.add(Refl.add(Refl.mul(x, p), x), p) : Nat}`. Both sides start with `1n+`, so `Equal.cong` with `n => 1n+n` gets you inside. Inside, `Refl.mul(1n+x, p)` is what the recursive call talks about."
  - text: "Inside, `Equal.trans` through `Refl.add(Refl.add(Refl.mul(x, p), p), x)`. The first step is the recursive call under `n => Refl.add(n, x)`. The second is the same three terms in a different order, and you have a lemma for that."
  - text: "`Equal.cong(Nat, Nat, n => 1n+n, Refl.add(Refl.mul(1n+x, p), x), Refl.add(Refl.add(Refl.mul(x, p), x), p), Equal.trans(Nat, Refl.add(Refl.mul(1n+x, p), x), Refl.add(Refl.add(Refl.mul(x, p), p), x), Refl.add(Refl.add(Refl.mul(x, p), x), p), Equal.cong(Nat, Nat, n => Refl.add(n, x), Refl.mul(1n+x, p), Refl.add(Refl.mul(x, p), p), succ_mul(x, p)), Addition.add_right_comm(Refl.mul(x, p), p, x)))`."
example_explanation: |-
  1. Identify the common outer constructor.
  2. `add_assoc` rearranges the expression inside it.
  3. Lift with `Equal.cong`. In the exercise first use the recursive call, then choose the rearrangement that aligns both sides.
---
`Refl.mul(1n+x, y) == Refl.add(Refl.mul(x, y), y)`. Multiplying by one more means adding one more copy of `y`. It's the partner of `succ_add`, and you'll need it for commutativity in the next level.

Match on `y` and read the **Goal** in the `1n+p` case. This goal is the longest so far, so go through it in order:

1. Both sides begin with `1n+`. Take that off first.
2. On the left, there's a `Refl.mul(1n+x, p)` inside a sum. The recursive call tells you what that equals, but only on its own. Use `Equal.cong` with `n => Refl.add(n, x)` to apply it inside the sum.
3. After that, compare the two sides. This is the first inductive step where the hypothesis isn't enough: they're the same sum in a different order.

Write it with holes first. `Equal.cong(Nat, Nat, n => 1n+n, a, b, ?inside)` lets **Goal** tell you what `?inside` still has to prove.

<!-- @conclusion -->
This is what most inductive steps in arithmetic look like: use the hypothesis, then rearrange.
