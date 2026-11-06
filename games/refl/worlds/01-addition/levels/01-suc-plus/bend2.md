---
title: "succ_add"
learning_goals:
  - "Induction on the argument the definition recurses on."
  - "`Refl.add(1n+x, y) == 1n+Refl.add(x, y)`: the mirror image of how `add` computes."
hints:
  - text: "Which argument does `Refl.add` look at? `match y:`, then `case 0n:` and `case 1n+p:`, with a `?a` and a `?b` in them."
  - text: "The `0n` case's goal is `{1n+x == 1n+x : Nat}`. The other is `{1n+Refl.add(1n+x, p) == 2n+Refl.add(x, p) : Nat}`, which has a `1n+` around this very statement for the smaller `p`."
  - text: "`case 0n:` is `{==}`. `case 1n+p:` is `Equal.cong(Nat, Nat, n => 1n+n, Refl.add(1n+x, p), 1n+Refl.add(x, p), succ_add(x, p))`."
example_explanation: |-
  1. `Refl.add` looks at its second argument, so match on `y`.
  2. `y = 0n`: both sides compute to `1n+x`, so `{==}`.
  3. `y = 1n+p`: both sides have a `1n+` around the smaller statement, so `Equal.cong` of the recursive call.
  The exercise has the same shape, with a different right side.
---
`Refl.add` says what `Refl.add(x, 1n+y)` is: the `1n+` moves outside. It says nothing about `Refl.add(1n+x, y)`, because addition only ever looks at its **second** argument. So that's
stuck until you know what `y` is, and to say what it equals for *every* `y` you need induction.

You did this once in the Tutorial, in `zero_add`. In Bend, induction is a `match` plus a recursive call:

```
def succ_add(x, y):
  match y:
    case 0n:
      ?a
    case 1n+p:
      ?b
```

Replace the template with that and press **Check**. Then select each hole and press **Goal**. Bend prints the goal after computing as far as it can, so read it carefully.

In the `1n+p` case you may call `succ_add(x, p)`: that's the induction hypothesis. `+x` in the statement means `x` may be used more than once, and you'll see that a lot from here on: a proof by recursion passes `x` along.

<!-- @conclusion -->
`Refl.add` tells you how to deal with a `1n+` on the right. `zero_add` and `succ_add` now handle `0n` and `1n+` on the left. With a lemma for each case, you can prove commutativity.
