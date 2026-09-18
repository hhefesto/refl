---
title: "Induction by `match`"
learning_goals:
  - "`match x:` with `case 0n:` and `case 1n+p:` splits a natural number; the recursive call on `p` is the induction hypothesis."
  - "`%zero_add(p) : {1n+Refl.add(0n, p) == 1n+_ : Nat}` rewrites the step goal with the induction hypothesis."
hints:
  - text: "`Refl.add(0n, x)` is stuck because `x` is on the right. Edit the `def` into a `match x:` with cases `0n` and `1n+p`."
  - text: "Case `0n`: `Refl.add(0n, 0n)` computes to `0n`, so `{==}`. Case `1n+p`: the goal is `{1n+Refl.add(0n, p) == 1n+p : Nat}`; `zero_add(p)` proves the inner equation."
    hidden: true
  - text: "Rewrite with it, marking the right side `p`: `%zero_add(p) : {1n+Refl.add(0n, p) == 1n+_ : Nat}`, then `{==}`."
    hidden: true
example_explanation: |-
  1. Define `copy` by recursion.
  2. Its zero case computes.
  3. In the successor case transport the smaller equality under `1n+_`, then use `{==}`. The exercise follows the same pattern for addition instead of copying.
---
`Refl.add(0n, x)` does not compute: the recursion is on the second argument
and `x` is a variable. Induction in Bend is a `match` on `x` plus a recursive
call: Bend checks that recursion is structural, so `zero_add(p)` inside the
`1n+p` branch is exactly the induction hypothesis.

Write the two cases yourself (there is no case-splitting command in Bend). In
the step, rewrite the goal with the recursive call: `_` marks the `p` on the
right of `zero_add(p) : {Refl.add(0n, p) == p : Nat}`.

<!-- @conclusion -->
Recursion is induction, and the checker's termination rule is what keeps that
honest. `zero_add` is in your inventory now.
