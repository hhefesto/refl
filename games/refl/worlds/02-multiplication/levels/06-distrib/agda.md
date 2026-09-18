---
example_explanation: |-
  1. Identify the common outer constructor.
  2. Associativity rearranges the expression inside it.
  3. Lift with `cong`. In the exercise first use the recursive hypothesis, then choose the rearrangement that aligns the endpoints.
hints:
- hidden: false
  text: Distributivity relates recursion on a sum to addition of two products.
- hidden: true
  text: Split `z`. The recursive equation leaves a new `+ x`; associativity aligns
    the parentheses.
- hidden: true
  text: The step has shape `trans (cong (_+ x) …) …`.
learning_goals:
- Distributivity by induction, with `+-assoc` in the step.
title: '*-distribˡ-+'
---
Distributivity relates recursion on a sum to addition of two products.

`x * (y + z) ≡ x * y + x * z`. The superscript `ˡ` says the factor is on
the left; type it as `\^l`.


<!-- @conclusion -->

The standard library names are `*-distribˡ-+` and `*-distribʳ-+`; you will
meet them by name in World 10.
