---
title: "Matching on rfl"
learning_goals:
  - "`rfl` is a constructor, so a proof of an equation can be taken apart with `cases`."
  - "Matching a proof against `rfl` makes the two sides the same."
hints:
  - text: "`cases p`. Then press **Goal**."
  - text: "It was `f x = f y`, and now it's `f x = f x`, because `y` has become `x`. What proves a thing equal to itself?"
  - text: "`cases p` on one line and `rfl` on the next."
example_explanation: |-
  1. `cases p` matches the equation against `rfl`.
  2. `b` becomes `a`, so the goal reads `a + 2 = a + 2`.
  3. `rfl` proves it. The exercise has an arbitrary function where this example has `· + 2`, but the two lines are the same.
---
You've been using `congrArg`, `Eq.symm` and `Eq.trans` as tools. This world opens the box and shows you what they're made of.

Remember the definition of equality:

```lean
inductive Eq : α → α → Prop where
  | refl (a : α) : Eq a a
```

It's an inductive type with one constructor, and you already know what to do with a value of an inductive type: use `cases`. So here's
the thing to try. You have `p : x = y` for two different variables `x` and `y`. There's only one constructor, so `p` has to be `rfl`. But
`rfl` only proves a thing equal to itself. What does Lean conclude?

To see the answer, press **Goal** before and after. Watch `y` in particular.

This level has you prove `congrArg` itself, under the name `cong'`. The real one is forbidden here, and so is `rw`, as using either would be
a little too easy.

<!-- @conclusion -->
That's the secret behind equality. Matching on `rfl` tells Lean that the two sides are the same, so it replaces one by the other everywhere,
in the goal and in the context.

`Eq.symm`, `Eq.trans` and `Eq.subst` are all a single line of this.
