---
title: "generalize"
learning_goals:
  - "`generalize e : t = b` replaces `t` by a new variable and keeps the equation."
  - "One tactic can do another's job in two steps."
hints:
  - text: "`unfold g`, then `generalize e : isZero n = b`. Press **Goal**: `b` has replaced the test, and `e : n.isZero = b` is above the line."
  - text: "`b` is a plain variable, so `cases b with` splits it. From there it's the last level's proof."
  - text: "`cases b with`, then `| true => exact absurd (isZero_true e) h`, and `| false => rfl`."
example_explanation: |-
  1. Replace the test by a new variable `b`, remembering the equation in `e`.
  2. Split on `b`.
  3. Reflect the `true` result into a contradiction, and the `false` branch is `rfl`. The exercise uses `generalize` for the same bookkeeping.
---
`cases e : t` is really two moves at once, and it's worth doing them separately once, because you'll sometimes want just the first.

```lean
  generalize e : isZero n = b
```

This finds every `isZero n` in the goal, replaces it with a brand-new variable `b`, and leaves you with `e : isZero n = b` above the line. Nothing has been split yet. `b` is just an unknown
`Bool`. But since it's a *variable*, you can now do anything with it that you can do to a variable.

The statement here is the previous level again, for the same function called `g`. Reprove it this way: unfold, generalize, then split on `b`.

Why bother? Because `cases` can't always find what you mean when the expression is complicated, while `generalize` says exactly which part you want to treat as unknown.

<!-- @conclusion -->
When you see `generalize` in a proof, read it as "from here on, I don't care what this term computes to, only that it's equal to this variable". Agda users know the same idea under the
names `with … in` and `inspect`.
