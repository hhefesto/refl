---
title: "add_comm"
learning_goals:
  - "Combining earlier lemmas with `exact`, `Eq.symm` and `rw`."
  - "The base case needs `zero_add`, the step needs `succ_add`."
  - "`exact` compares up to computation; `rw` looks for the exact shape."
hints:
  - text: "Use `induction y with`. In the `zero` case the goal is `x + zero = zero + x`. `zero_add x` says `0 + x = x`, so you need it the other way round."
  - text: "`exact Eq.symm (zero_add x)` closes the base case. In the `succ` case the goal is `x + y.succ = y.succ + x`. Unfold the left with `add_succ`, use `ih`, and the right is what `succ_add` talks about."
  - text: "`| zero => exact Eq.symm (zero_add x)`, and `| succ y ih => rw [add_succ, ih, succ_add]`."
example_explanation: |-
  1. `x + 1` computes to `succ x`, but `1 + x` is stuck.
  2. So work on the stuck side: `succ_add zero x` gives `1 + x = succ (zero + x)`, then `zero_add x` goes inside `succ` with `congrArg`.
  3. Chain with `Eq.trans`, and flip with `Eq.symm` because the goal wants `x + 1` on the left.
  For the exercise, induct on `y`, using `zero_add` at zero and `succ_add` with `ih` at `succ`.
---
Commutativity: `x + y = y + x`. Everybody knows it, and it's the first proof here
that takes real planning.

You have the two lemmas it needs: `zero_add` and `succ_add`, one for each case of
the induction. The difficulty is that they rarely fit the goal as they stand. A lemma
points in one direction and your goal may want the other, so `Eq.symm` flips it, or
`rw [← h]` rewrites backwards.

There's one trap, and it's worth understanding now. After `induction`, the base case
says `zero`, but `zero_add` says `0`. Those are equal by computation, but they aren't
written the same. **`rw` looks for the exact shape**, so `rw [zero_add]` won't find
it. **`exact` compares up to computation**, so `exact` is happy with it.

Do the `induction` first, then press **Goal** in each case. One side will have computed
and the other will be stuck in a shape one of your lemmas talks about.

<!-- @conclusion -->
This proof works, but as `rw` chains grow you lose sight of what the goal looks like
along the way. Two levels from now, `calc` writes those steps down.
