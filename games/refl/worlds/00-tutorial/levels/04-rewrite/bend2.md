---
title: "rewrite"
learning_goals:
  - "`%h : P` rewrites the goal with `h : {a == b : T}`: `P` is the goal with `_` marking `b`, and the goal becomes `P` with `a` there."
  - "To rewrite the other way, flip the equation with `Equal.sym`."
hints:
  - text: "The goal is `{Refl.add(x, 2n) == 5n : Nat}` and `h : {x == 3n : Nat}`. Mark where `3n` sits in the goal: `5n` is `2n+3n`."
  - text: "Write `%h : {Refl.add(x, 2n) == 2n+_ : Nat}` on its own line. The goal becomes `{Refl.add(x, 2n) == 2n+x : Nat}`, which computes to `{2n+x == 2n+x : Nat}`."
    hidden: true
  - text: "Then `{==}` on the next line. Two lines, both indented under the `def`."
    hidden: true
example_explanation: |-
  1. View `5n` as `1n+4n`.
  2. The transport motive marks that `4n` endpoint with `_`, reducing the goal to `Refl.add(n, 1n) == 1n+n`.
  3. Both sides compute alike, so `{==}` closes it. Transfer the motive construction using the exercise's own constants.
---
`%h : P` is a rewrite along the equation `h : {a == b : T}`. You write `P`,
the goal with `_` marking the occurrences of the **right-hand** side `b`; Bend
checks that `P` with `b` is the current goal, and continues with `P` with `a`.

Here `b` is `3n`, which hides inside `5n` (`5n` is `2n+3n`), so the motive is
`{Refl.add(x, 2n) == 2n+_ : Nat}`. Afterwards `Refl.add(x, 2n)` and `2n+x`
compute to the same term and `{==}` finishes.

<!-- @conclusion -->
Note the direction: `%h` replaces the marked *right* side of `h` by its left
side. If you need the other direction, rewrite with `Equal.sym(T, a, b, h)`.
