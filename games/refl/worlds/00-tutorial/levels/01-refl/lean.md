---
title: "refl"
learning_goals:
  - "In Lean the statement is a `theorem` and the proof is the tactic block after `by`."
  - "`rfl` proves `a = b` whenever both sides compute to the same value."
hints:
  - text: "The proof is the indented block after `by`. Replace `sorry` with one tactic."
  - text: "`rfl` closes a goal `a = b` when both sides compute to the same thing; `2 + 2` computes to `4` by the definition of `+` on `MyNat`."
    hidden: true
  - text: "Type `  rfl` (two spaces, then `rfl`) as the whole proof and press **Check**."
    hidden: true
example_explanation: |-
  1. The declaration fixes both endpoints.
  2. Addition computes to `4` on the left.
  3. `rfl` checks that the endpoints agree. The exercise uses different numerals, with the same computation test.
---
Your first Lean proof. The statement is a `theorem` whose proof is a *tactic
block*: everything indented after `by`. Right now that block is `sorry`, a
placeholder Lean accepts with a warning. Your job is to replace it.

The loop: edit the block, **Check** (`C-c C-l`), read the remaining goal in the
right panel (`⊢ 2 + 2 = 4`), edit again. Put the cursor inside the block and
press **Goal** (`C-c C-,`) to see the goal at that point.

<!-- @conclusion -->
`rfl` is Lean's "both sides are the same": the kernel computes `2 + 2` and
`4` to the same `MyNat` and accepts. Most of this world is learning to bring a
goal to the point where `rfl` works.
