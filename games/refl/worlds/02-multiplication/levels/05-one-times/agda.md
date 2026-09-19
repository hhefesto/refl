---
title: "one-*"
learning_goals:
  - "Chaining two inventory lemmas."
hints:
  - text: "`*-comm 1 x` then `*-one x`."
    hidden: true
example_explanation: |-
  1. The outer `+ 0` computes away by the definition of addition.
  2. `*-comm 1 x` changes `1 * x` into `x * 1`.
  3. The previously proved `*-one x` removes multiplication by one on the right; `trans` connects the steps.
  Start by asking which simplifications compute and which require an earned lemma.
---
A one-liner from `*-comm` and `*-one`.

<!-- @conclusion -->
When a lemma follows from others without induction, it does not need a case
split — reach for `trans`.
