---
title: "mul_one"
learning_goals:
  - "Unfold a definition by hand: `x * 1` is `x * zero + x`, which is `zero + x`."
  - "`exact` accepts a lemma whose type only computes to the goal."
hints:
  - text: "Unfold `x * 1` on paper: `1` is `succ zero`, so the second clause gives `x * zero + x`, and the first gives `zero + x`. You've seen that equation before."
  - text: "`exact zero_add x`. Its type says `0 + x = x`, and the goal computes to that."
example_explanation: |-
  1. Unfold: `x * 2` is `x * succ 1`, which computes to `x * 1 + x`, then to `(zero + x) + x`.
  2. `zero + x` is stuck, but `zero_add x` says it equals `x`. `congrArg (· + x)` places that under the outer `+ x`.
  For the exercise, `x * 1` unfolds one step less, to `zero + x`, so `zero_add` alone finishes it.
---
Multiplication works like addition: it looks at its **second** argument.

```lean
def mul : MyNat → MyNat → MyNat
  | _, zero => zero
  | m, succ n => mul m n + m
```

So a multiplication with a known number on the right computes, even with a variable on the left.
Follow it through for `x * 1`, remembering that `1` is `succ zero`: first the second clause, then the
first.

Lean's **Goal** will show you `x * 1 = x`, as you wrote it, so do this on paper. It stops before
reaching `x`. Addition has got in the way, and it's stuck, since addition can't see through a variable
on the right.

But that stuck term isn't new. Nothing here needs an induction: one lemma from your inventory
finishes it, and `exact` checks that its type matches the goal by computing.

<!-- @conclusion -->
`x * 0 = 0` holds by computation and never needs a lemma, just like `x + 0 = x`. And `x * 1` very
nearly computes to `x`, except for that `0 +` left over, which you had to pay for back in the Tutorial.
