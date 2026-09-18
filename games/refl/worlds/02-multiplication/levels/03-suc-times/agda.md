---
example_explanation: |-
  1. Identify the common outer constructor.
  2. Associativity rearranges the expression inside it.
  3. Lift with `cong`. In the exercise first use the recursive hypothesis, then choose the rearrangement that aligns the endpoints.
hints:
- hidden: false
  text: An induction step may need an algebraic rearrangement after the recursive
    proof.
- hidden: true
  text: Split `y`; remove the common outer successor. Lift the recursive equation
    through addition of `x`.
- hidden: true
  text: Start the step with `cong suc (trans … …)`; the remaining equality swaps the
    last two summands.
learning_goals:
- An inductive step that needs a rearrangement lemma from the inventory.
- 'Sections on the right: `(_+ x)`.'
title: suc-*
---
An induction step may need an algebraic rearrangement after the recursive proof.

`suc x * y ≡ x * y + y`. The step case is the first one where the
induction hypothesis alone is not enough: after using it, the two sides
are the same sum in a different order.


<!-- @conclusion -->

Write the step as a `begin` block if the nested `cong`/`trans` gets
confusing; that is what the notation is for.
