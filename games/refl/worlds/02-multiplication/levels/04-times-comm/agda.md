---
example_explanation: |-
  1. Draw the endpoints: `a → b` and `c → b`.
  2. Reverse the second edge to obtain `b → c`.
  3. Compose with `trans`. The exercise reverses a different edge; match endpoints before composing.
hints:
- hidden: false
  text: Multiplication commutativity mirrors the earlier addition proof.
- hidden: true
  text: Split `y`. Use `zero-*` backwards in the base case and `suc-*` backwards after
    the step hypothesis.
- hidden: true
  text: The step begins `trans (cong (_+ x) …) …`.
learning_goals:
- The same proof skeleton as `+-comm`, with `zero-*` and `suc-*` in place of `zero-+`
  and `suc-+`.
title: '*-comm'
---
Multiplication commutativity mirrors the earlier addition proof.

Look back at your `+-comm` proof: this one has the same shape.


<!-- @conclusion -->

The two commutativity proofs are the same *program* over different
operations. World 8 (records) turns that observation into a structure: a
commutative semiring proved once, instantiated many times.
