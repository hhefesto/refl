---
title: "Refine and Normalise"
learning_goals:
  - "Numerals compute: `(x + 2) + 1` and `x + 3` unfold to the same `succ (succ (succ x))`."
  - "When both sides compute to the same term, `rfl` is the whole proof."
hints:
  - text: "Ask for the **Goal** and think about what `x + 3` unfolds to, step by step, by the definition of `+`."
  - text: "`+` recurses on its second argument, so `x + 3` is `succ (x + 2)`, which is `succ (succ (x + 1))`, and so on. `(x + 2) + 1` unfolds to the same."
    hidden: true
  - text: "`  rfl` closes it: no rewriting needed."
    hidden: true
example_explanation: |-
  1. Expand the two additions on their numeric right arguments.
  2. Both sides become `succ (succ n)`.
  3. `rfl` checks this directly. The exercise has a longer numeral but uses the same rule.
---
Nothing here needs a lemma. `MyNat` addition recurses on its second argument,
so any expression whose second summand is a numeral unfolds all the way to
successors. Both sides of `(x + 2) + 1 = x + 3` become `succ (succ (succ x))`,
and `rfl` sees it.

<!-- @conclusion -->
Before reaching for a lemma, ask what computes. `rfl` checks definitional
equality, and numerals on the right of `+` always compute.
