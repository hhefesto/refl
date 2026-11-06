---
title: "Proofs as lambdas"
learning_goals:
  - "`e => …` is an anonymous function, and its body can be several lines."
  - "A proof can be handed over as a function, without naming its argument in the `def`."
hints:
  - text: "The goal is a function type, so start with `e =>` and a new line under it, indented further, with `?g` on it. **Goal** on `?g` says `{y == x : A}`."
  - text: "Mark the `x` on the right: `%e : {_ == x : A}`. The goal is then a thing equal to itself, so `{==}`."
  - text: "`e =>`, then `%e : {_ == x : A}`, then `{==}`, with the last two indented under the first."
example_explanation: |-
  1. The anonymous function takes an equality.
  2. A rewrite with it unifies the two sides.
  3. Their successors now agree by `{==}`. In the exercise the target reverses the sides instead.
---
Up to now, you've named a proof's arguments in the `def`. Sometimes you'll want a small function in the middle of an expression. You've already seen these: `Equal.cong(Nat, Nat, n => 1n+n, …)`.

A lambda's body can be more than one line, if it starts on the next line and is indented:

```
e =>
  %e : {_ == x : A}
  {==}
```

The statement here ends in a function type, so the `def` has only three parameters. Your proof must return a function. Prove `Equal.sym`, under the name `sym_`, by writing a lambda that takes the equation and rewrites with it. The real one is forbidden here.

This is the same move as this world's first level, in a different spelling.

<!-- @conclusion -->
You'll see these all over real code. They're the usual way to pass a small proof to something else, without naming it, as you did in `Logic.and_swap_iff`.
