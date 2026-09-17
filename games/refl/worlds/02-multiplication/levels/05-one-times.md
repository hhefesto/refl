---
id: one-times
index: 5
title: "one-*"
learning_goals:
  - "Chaining two inventory lemmas."
unlocks:
  lemmas:
    - name: "one-*"
      agda: "one-*"
      lean: "one_mul"
hints:
  - text: "`*-comm 1 x` then `*-one x`."
    hidden: true
---
A one-liner from `*-comm` and `*-one`.

<!-- @conclusion -->
When a lemma follows from others without induction, it does not need a case
split — reach for `trans`.
