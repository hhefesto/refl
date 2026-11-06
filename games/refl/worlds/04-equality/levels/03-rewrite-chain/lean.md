---
learning_goals:
  - "`rw [p, q]` applies several equations in order."
  - "Direction matters: `rw` uses the equation left to right; `←` flips it."
hints:
  - text: "The goal mentions `x` and `y`, and you have an equation for each. `rw [p, q]`, then press **Goal**."
  - text: "It says `2 + 3 = 5`. `rw` tried `rfl` when it finished, but only a weak one that doesn't compute additions. You know the stronger one."
  - text: "`rw [p, q]` on one line and `rfl` on the next."
example_explanation: |-
  1. Rewrite the first variable with `p`.
  2. Rewrite the second with `q`.
  3. The remaining numeric equality computes. Use the same order of substitutions with the exercise's hypotheses.
---
You've used `rw` with one equation, and in the odd chain since. Let's look at what it does more carefully, as you'll use it for the rest of the game.

```lean
  rw [eq₁, eq₂]
```

The equations run in order, each one working on the goal the last one left. Here `p : x = 2` and `q : y = 3`, and the goal is `x + y = 5`.

Two details are worth knowing, for the day a `rw` doesn't do what you want. An equation rewrites from left to right: every occurrence of its left side
becomes its right side. If you need the other direction, write `rw [← p]`. And each equation only sees the goal *as the previous one left it*, so the order
can matter.

Afterwards, `rw` tries to close the goal with `rfl`, but only a weak form of it. Press **Goal** to see what's left.

<!-- @conclusion -->
Real proofs are full of these chains, sometimes several lemmas long. Read one the way Lean does, one equation at a time.
