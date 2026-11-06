---
title: "mul_one"
learning_goals:
  - "Bend computes the goal for you: `Refl.mul(x, 1n)` becomes `Refl.add(0n, x)`."
  - "Reuse `zero_add`."
hints:
  - text: "Press **Goal**. It says `{Refl.add(0n, x) == x : Nat}`. You've seen that equation before."
  - text: "`Tutorial.zero_add(x)`."
example_explanation: |-
  1. Bend computes `Refl.mul(x, 2n)` to `Refl.add(Refl.add(0n, x), x)`.
  2. `Refl.add(0n, x)` is stuck, but `zero_add(x)` says it equals `x`. `Equal.cong` with `n => Refl.add(n, x)` places that under the outer addition.
  For the exercise, `Refl.mul(x, 1n)` unfolds one step less, so `zero_add` alone finishes it.
---
Multiplication works like addition: it looks at its **second** argument.

```
def mul(a, b):
  match b:
    case 0n:
      0n
    case 1n+p:
      add(mul(a, p), a)
```

So a multiplication with a known number on the right computes, even with a variable on the left. Follow it through for `Refl.mul(x, 1n)`: first the second case, then the first.

Check yourself: select the hole and press **Goal**. It stops before reaching `x`. Addition has got in the way, and it's stuck, since addition can't see through a variable on the right.

But that stuck term isn't new. Nothing here needs an induction: one lemma from your inventory finishes it.

<!-- @conclusion -->
`Refl.mul(x, 0n)` computes to `0n` and never needs a lemma, just like `Refl.add(x, 0n)`. And `Refl.mul(x, 1n)` very nearly computes to `x`, except for that `0n` left over, which you had to pay for back in the Tutorial.
