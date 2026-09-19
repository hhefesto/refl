---
learning_goals:
  - "`rw [h]` replaces the left side of `h` by its right side in the goal."
  - "`rw [← h]` rewrites in the other direction."
hints:
  - text: "The goal is `x + 2 = 5` and `h : x = 3`. Make the goal about `3` instead of `x`."
  - text: "`rw [h]` turns the goal into `3 + 2 = 5`. `rw` then tries `rfl` on its own; if a goal remains, finish with `rfl`."
    hidden: true
  - text: "The proof is two lines: `  rw [h]` then `  rfl` (the second is harmless if the first already closed the goal)."
    hidden: true
example_explanation: |-
  1. Rewrite `n` to `4`.
  2. The resulting equality is `4 + 1 = 5`.
  3. `rfl` computes the addition. Transfer this sequence using the exercise's own hypothesis and constants.
---
`rw [h]` rewrites with an equation `h : a = b`: every `a` in the goal becomes
`b`. With `h : x = 3` the goal `x + 2 = 5` becomes `3 + 2 = 5`, and `3 + 2`
computes to `5`. `rw` finishes by trying `rfl`, so the goal often closes in the
same step. To rewrite right-to-left, write `rw [← h]`.

<!-- @conclusion -->
Rewriting is the workhorse of tactic proofs: `rw [h₁, h₂]` chains several
equations left to right.
