---
title: "Induction with `induction`"
learning_goals:
  - "`induction x with | zero => … | succ n ih => …` splits into base and step, naming the induction hypothesis."
  - "`add_succ` unfolds `a + succ b` to `succ (a + b)`."
hints:
  - text: "`0 + x` does not compute (the variable is on the right). Induct on `x`."
  - text: "`induction x with` gives two goals. Base: `0 + 0 = 0` is `rfl`. Step: with `ih : 0 + n = n`, the goal `0 + succ n = succ n` unfolds by `add_succ` to `succ (0 + n) = succ n`."
    hidden: true
  - text: "Step case: `rw [add_succ, ih]`. Full proof:\n\n```lean\n  induction x with\n  | zero => rfl\n  | succ n ih => rw [add_succ, ih]\n```"
    hidden: true
example_explanation: |-
  1. Define `copy` by zero/successor recursion.
  2. The zero branch computes.
  3. In the successor branch, `rw [copy]` unfolds one step of the definition, then `rw [ih]` finishes. In the exercise the unfolding lemma is `add_succ` instead of `copy`.
---
`0 + x` is stuck: addition recurses on its second argument and `x` is a
variable. The way through is induction. `induction x with` opens one branch per
constructor; in the `succ n ih` branch, `ih` is the statement for `n`, the
induction hypothesis.

In the step, rewrite `0 + succ n` to `succ (0 + n)` with the lemma `add_succ`
from the prelude, then `ih` turns it into `succ n = succ n`.

<!-- @conclusion -->
Induction is recursion: the `succ` branch may use the statement for `n`.
`zero_add` is in your inventory.
