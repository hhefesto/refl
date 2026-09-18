---
example_explanation: |-
  1. Split the recursive input into `zero` and `suc n`.
  2. The base equation computes.
  3. In the step, `example n` proves the smaller equation; `cong suc` lifts it. Transfer the choice of recursion variable and the lifted induction hypothesis to the exercise.
hints:
- hidden: false
  text: Associativity changes parentheses while preserving the order of summands.
- hidden: true
  text: 'Choose `z`: it is the outer right argument on both sides. The successor case
    exposes matching constructors.'
- hidden: true
  text: Use `+-assoc x y (suc z) = cong suc …`.
learning_goals:
- A proof by induction where every case is `refl` or `cong suc`.
- 'Reading parentheses: `x + y + z` means `(x + y) + z` because `_+_` is `infixl 6`.'
title: +-assoc
---
Associativity changes parentheses while preserving the order of summands.

Associativity. Choose the induction variable so that both sides compute one
`suc` per step.


<!-- @conclusion -->

`_+_` was declared `infixl 6`, so `x + y + z` parses as `(x + y) + z`. The
standard library's `+-assoc` has exactly this statement.
