---
title: "Inside a rewrite"
learning_goals:
  - "`%p : P` is what you do with a proof of an equation: it's the only way to use one."
  - "After a rewrite the two sides are the same, and `{==}` proves that."
hints:
  - text: "The goal is `{f(x) == f(y) : B}`, and `p : {x == y : A}`. Mark the `y` in the goal: `%p : {f(x) == f(_) : B}`."
  - text: "Press **Goal** after that line: it's `{f(x) == f(x) : B}`. What proves a thing equal to itself?"
  - text: "`%p : {f(x) == f(_) : B}`, then `{==}`."
example_explanation: |-
  1. Mark the `b` on the right side of the goal with `_`.
  2. The rewrite replaces it by `a`, so the goal reads `{Refl.add(a, 2n) == Refl.add(a, 2n) : Nat}`.
  3. `{==}` proves it. The exercise has an arbitrary function where this example has `Refl.add`, but the two lines are the same.
---
You've been using `Equal.cong`, `Equal.sym` and `Equal.trans` as tools. This world opens the box and shows you what they're made of.

Equality has one way to make a proof, `{==}`, which only proves a thing equal to itself. And it has one way to use a proof, the rewrite you've already met:

```
%e : P
```

With `e : {a == b : T}`, `P` is the goal with `_` marking `b`, and the goal becomes `P` with `a` there. Everything Bend knows about equality comes down to that.

Bend has no pattern for matching on `{==}`, so this is the only way in. So what would the rewrite do here? You have `p : {x == y : A}`, for two different variables. Mark the `y` in the goal. Then ask for the **Goal**, and watch what's become of `y`.

This level has you prove `Equal.cong` itself, under the name `cong_`. The real one is forbidden here, as using it would be a little too easy.

<!-- @conclusion -->
That's the secret behind equality. A rewrite says that the two sides are interchangeable, and then the goal is about one thing.

`Equal.sym` and `Equal.trans` in Base are each a line of this.
