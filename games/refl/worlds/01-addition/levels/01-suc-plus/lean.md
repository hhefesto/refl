---
title: "succ_add"
learning_goals:
  - "Induction on the argument the definition recurses on."
  - "`succ x + y = succ (x + y)`: the mirror image of the defining clause `add_succ`."
hints:
  - text: "Which argument does `+` look at? Start with `induction y with`, then a line `| zero => sorry` and a line `| succ y ih => sorry`."
  - text: "The `zero` case closes with `rfl`. In the `succ` case the goal is `x.succ + y.succ = (x + y.succ).succ`, and `ih : x.succ + y = (x + y).succ`. Two additions there have `.succ` on the right, so `rw [add_succ]` applies twice."
  - text: "`| zero => rfl`, and `| succ y ih => rw [add_succ, add_succ, ih]`."
example_explanation: |-
  1. `+` looks at its second argument, so induct on `y`.
  2. `y = zero`: both sides compute to `succ x`, so `rfl`.
  3. `y = succ y`: unfold the left with `add_succ`, use `ih`, and `rfl` finishes because the right side computes to the same term.
  The exercise has the same shape, with one more `add_succ` to unfold.
---
The definition of `+` says what `x + succ y` is: the `succ` moves outside. Lean
knows this as `add_succ`. It says nothing about `succ x + y`, because addition only
ever looks at its **second** argument. So `succ x + y` is stuck until you know what
`y` is, and to say what it equals for *every* `y` you need induction.

You did this once in the Tutorial, in `zero_add`. Here's the shape again:

```lean
  induction y with
  | zero => sorry
  | succ y ih => sorry
```

Put the cursor on each `sorry` and press **Goal**. A note on reading what you see:
Lean prints `succ x` as `x.succ`, which is the same thing. In the `succ` case you
have `ih` above the line, the lemma for the smaller `y`. Below the line are some
additions with `.succ` on the right, which is what `rw [add_succ]` unfolds.

<!-- @conclusion -->
The definition of `+` tells you how to deal with a `succ` on the right. `zero_add`
and `succ_add` now handle `zero` and `succ` on the left. With a lemma for each case,
you can prove commutativity.
