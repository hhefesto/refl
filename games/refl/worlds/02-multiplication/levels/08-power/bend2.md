---
learning_goals:
  - "Bend computes `Refl.pow` two steps for you."
  - "`Equal.cong` to change only the left factor."
hints:
  - text: "Press **Goal**. It says `{Refl.mul(Refl.mul(1n, x), x) == Refl.mul(x, x) : Nat}`. Only one part of the left side isn't already on the right."
  - text: "`Multiplication.one_mul(x)` turns `Refl.mul(1n, x)` into `x`. Use it under `n => Refl.mul(n, x)`."
  - text: "`Equal.cong(Nat, Nat, n => Refl.mul(n, x), Refl.mul(1n, x), x, Multiplication.one_mul(x))`."
example_explanation: |-
  1. `Refl.pow(x, 1n)` computes to `Refl.mul(1n, x)`.
  2. That's stuck, and `one_mul(x)` is exactly that equation.
  For the exercise, `Refl.pow(x, 2n)` unfolds one step further, so you need `Equal.cong` as well.
---
Powers are defined the way products are, again by looking at the second argument:

```
def pow(a, b):
  match b:
    case 0n:
      1n
    case 1n+p:
      mul(pow(a, p), a)
```

Prove that `Refl.pow(x, 2n)` really is `Refl.mul(x, x)`. There's no induction here, because the `2n` is known and the definition can run. Before you use any lemma, ask for the **Goal** and see how far it gets.

This is a good habit in general: **compute first, then find the one place that doesn't compute**. Most of the term usually takes care of itself, and what's left is small.

To change one factor of a product and leave the other alone, give `Equal.cong` a function that holds the other factor fixed. Which function would hold `x` on the right?

<!-- @conclusion -->
Two steps of `pow` left only one stuck piece, which `one_mul` took care of. The reading level that closes this world connects distributivity to sums.
