---
title: "cong"
learning_goals:
  - "`Equal.cong(A, B, f, a, b, e)` maps `e : {a == b : A}` through `f` to `{f(a) == f(b) : B}`."
  - "`%h : P` rewrites the goal with `h`; `P` is the goal with `_` where the right side of `h` sits."
hints:
  - text: "You have `h : {x == y : Nat}` and need `{1n+x == 1n+y : Nat}`: apply successor to both sides."
  - text: "`Equal.cong(Nat, Nat, n => 1n+n, x, y, h)`: the function is the lambda `n => 1n+n`, the endpoints are `x` and `y`."
    hidden: true
  - text: "Or rewrite: `%h : {1n+x == 1n+_ : Nat}` on one line (`_` marks the `y`), then `{==}` on the next."
    hidden: true
example_explanation: |-
  1. The law gives equality evidence `h`.
  2. Supply the shared surrounding function to `Equal.cong`.
  3. It lifts the evidence to the function's outputs. For the exercise use the successor function instead of addition by two.
---
Equality is a congruence: from `h : {x == y : Nat}` follows
`{1n+x == 1n+y : Nat}`. Base has `Equal.cong(A, B, f, a, b, e)` for that; the
function argument is a lambda, `n => 1n+n`.

The other road is rewriting with `%h : P`: `P` is the goal with `_` marking the
*right-hand* side of `h` (`y`); after that line the goal has `x` there, and
`{==}` finishes.

<!-- @conclusion -->
`Equal.cong` is `cong`. Rewriting with `%` is Bend's `rewrite`, and it goes
in the direction "replace the marked right side by the left side".
