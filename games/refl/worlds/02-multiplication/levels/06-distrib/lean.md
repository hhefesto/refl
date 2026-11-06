---
title: "mul_add"
learning_goals:
  - "Distributivity by induction, with `add_assoc` in the step."
hints:
  - text: "`induction z with`. The `succ` case's goal is `x * (y + z.succ) = x * y + x * z.succ`. Unfold with `add_succ` and `mul_succ` until you can use `ih`."
  - text: "`rw [add_succ, mul_succ, mul_succ]` gives `x * (y + z) + x = x * y + (x * z + x)`. Then `ih` gives `x * y + x * z + x = x * y + (x * z + x)`, which only moves parentheses."
  - text: "`| zero => rfl`, and `| succ z ih => rw [add_succ, mul_succ, mul_succ, ih, add_assoc]`."
example_explanation: |-
  1. Induct on `z`, the argument on which the inner addition computes. At zero the right side contains `0 + x`, so use `zero_add x` backwards under `x * y + ·`.
  2. At `succ z`, unfold the multiplication, then use `ih`.
  3. The summands are associated differently, and `add_assoc` finishes the step.
---
`x * (y + z) = x * y + x * z`, the law that links the two operations.

Which variable should you induct on? Look at the left side: the multiplication looks at `y + z`, and that sum looks
at `z`. On the right side `x * z` looks at `z` too. That's the same reasoning you used for `add_assoc`, and it picks
out one variable.

The `zero` case computes away. In the `succ` case, unfold with `add_succ` and `mul_succ` and press **Goal**. Each side
has gained a `+ x`, but not in the same position: on the left it sits around the whole product, and on the right it's
inside the second summand. So there are two more steps. Use `ih`, and then deal with the parentheses.

<!-- @conclusion -->
You now have the law that lets you multiply out any product of sums. Lean's Mathlib library has this lemma under the
same name, `mul_add`.
