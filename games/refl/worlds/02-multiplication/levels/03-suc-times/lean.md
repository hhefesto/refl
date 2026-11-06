---
title: "succ_mul"
learning_goals:
  - "An inductive step that needs a rearrangement lemma from the inventory."
  - "`rw` works one step at a time, and **Goal** shows you each."
hints:
  - text: "`induction y with`. In the `succ` case the goal is `x.succ * y.succ = x * y.succ + y.succ`. Unfold with `mul_succ` twice and `add_succ` twice."
  - text: "That leaves `(x.succ * y + x).succ = (x * y + x + y).succ`. Now `ih` rewrites `x.succ * y`, leaving `(x * y + y + x).succ = (x * y + x + y).succ`: the same three terms in a different order."
  - text: "`| zero => rfl`, and `| succ y ih => rw [mul_succ, mul_succ, add_succ, add_succ, ih, add_right_comm]`."
example_explanation: |-
  1. Identify the common outer constructor.
  2. `add_assoc` rearranges the expression inside it, and `rw` works under the `succ` without help.
  In the exercise first use the hypothesis, then choose the rearrangement that aligns both sides.
---
`succ x * y = x * y + y`. Multiplying by one more means adding one more copy of `y`. It's the partner of
`succ_add`, and you'll need it for commutativity in the next level.

Induct on `y`, and read the **Goal** in the `succ` case. This proof is one long `rw`, so build it a step at
a time. Add one rewrite, put the cursor at the end of the line, press **Goal**, and look at what's changed:

1. Unfold the products with `mul_succ` and the additions with `add_succ`, until nothing with `.succ` on the
   right of an operator remains.
2. Now both sides are a `succ` of a sum, and `ih` tells you what the product on the left equals. `rw` works
   inside a term, so you don't need a section for this.
3. After that, compare the two sides. This is the first inductive step where the hypothesis isn't enough:
   they're the same sum in a different order.

<!-- @conclusion -->
This is what most inductive steps in arithmetic look like: use the hypothesis, then rearrange.
