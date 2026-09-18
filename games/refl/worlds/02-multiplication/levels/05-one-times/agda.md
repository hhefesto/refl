---
example_explanation: |-
  1. Draw the endpoints: `a → b` and `c → b`.
  2. Reverse the second edge to obtain `b → c`.
  3. Compose with `trans`. The exercise reverses a different edge; match endpoints before composing.
hints:
- hidden: false
  text: A theorem can follow by composition, without a new induction.
- hidden: true
  text: First commute `1 * x`, then use the right identity theorem.
- hidden: true
  text: Use `trans … …` with the intermediate term `x * 1`.
learning_goals:
- Chaining two inventory lemmas.
title: one-*
---
A theorem can follow by composition, without a new induction.

A one-liner from `*-comm` and `*-one`.


<!-- @conclusion -->

When a lemma follows from others without induction, it does not need a case
split — reach for `trans`.
