---
title: "cong"
learning_goals:
  - "`congrArg f h` turns `h : a = b` into `f a = f b`."
  - "`rw [h]` rewrites the goal with an equation and closes it when it becomes `x = x`."
hints:
  - text: "You have `h : x = y` and need `succ x = succ y`: apply `succ` to both sides of `h`."
  - text: "`exact congrArg succ h` does exactly that. Alternatively, `rw [h]` replaces `x` by `y` in the goal, leaving `succ y = succ y`, which `rw` closes by itself."
    hidden: true
  - text: "Either `  exact congrArg succ h` or `  rw [h]` is the whole proof."
    hidden: true
example_explanation: |-
  1. Name the input equation `h`.
  2. `rw [h]` replaces `a` by `b` inside the addition.
  3. The identical endpoints close. In the exercise rewriting takes place under `succ` instead.
---
Equality is a congruence: from `h : x = y` you may conclude `f x = f y` for
any function `f`. In Lean that is `congrArg f h`, and `exact` hands a finished
proof term to the goal.

The tactic `rw [h]` is the other road: it *rewrites* the goal, replacing the
left side of `h` (`x`) by its right side (`y`) everywhere, and then tries `rfl`.

<!-- @conclusion -->
`congrArg` is `cong`, and `rw` is how Lean proofs usually move an equation
into the goal. Both are in your inventory now.
