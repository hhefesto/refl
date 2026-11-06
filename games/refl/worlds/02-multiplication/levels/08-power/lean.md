---
learning_goals:
  - "Unfolding `^` two steps."
  - "`congrArg` with `(· * x)`, to change only the left factor."
hints:
  - text: "Unfold `x ^ 2` on paper. `2` is `succ 1`, so it's `x ^ 1 * x`, and that's `(x ^ 0 * x) * x`, which is `(1 * x) * x`. Only the inner `1 * x` isn't already on the right."
  - text: "`one_mul x` turns `1 * x` into `x`. Use it under `(· * x)`: `exact congrArg (· * x) (one_mul x)`."
example_explanation: |-
  1. Unfold: `x ^ 1` is `x ^ 0 * x`, which computes to `1 * x`.
  2. `1 * x` is stuck, and `one_mul x` is exactly that equation.
  For the exercise, `x ^ 2` unfolds one step further, to `(1 * x) * x`, so you need `congrArg` as well.
---
Powers are defined the way products are, again by looking at the second argument:

```lean
def pow : MyNat → MyNat → MyNat
  | _, zero => succ zero
  | m, succ n => pow m n * m
```

Prove that `x ^ 2` really is `x * x`. There's no induction here, because the `2` is known and the definition can run.
Lean's **Goal** shows `x ^ 2 = x * x` as written, so work out on paper how far it computes.

This is a good habit in general: **compute first, then find the one place that doesn't compute**. Most of the term
usually takes care of itself, and what's left is small.

To change one factor of a product and leave the other alone, use `congrArg` with a function that holds the other factor
fixed. `(· * x)` means `fun w => w * x`. `exact` will check that the result computes to your goal.

<!-- @conclusion -->
Two steps of `^` left only one stuck piece, which `one_mul` took care of. The reading level that closes this world
connects distributivity to sums.
