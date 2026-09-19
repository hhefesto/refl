---
title: "suc-*"
learning_goals:
  - "An inductive step that needs a rearrangement lemma from the inventory."
  - "Sections on the right: `(_+ x)`."
hints:
  - text: "Induction on `y`. Normalise both sides in the step: left is `suc (suc x * y + x)`, right is `suc (x * y + x + y)`."
  - text: "Under `cong suc`, rewrite `suc x * y` with the induction hypothesis (`cong (_+ x) (suc-* x y)`), leaving `x * y + y + x ≡ x * y + x + y`, which is `+-right-comm`."
  - text: "Step: `cong suc (trans (cong (_+ x) (suc-* x y)) (+-right-comm (x * y) y x))`."
    hidden: true
example_explanation: |-
  1. Identify the common outer constructor.
  2. Associativity rearranges the expression inside it.
  3. Lift with `cong`. In the exercise first use the recursive hypothesis, then choose the rearrangement that aligns the endpoints.
---
`suc x * y ≡ x * y + y`. The step case is the first one where the
induction hypothesis alone is not enough: after using it, the two sides
are the same sum in a different order.

<!-- @conclusion -->
Write the step as a `begin` block if the nested `cong`/`trans` gets
confusing; that is what the notation is for.
