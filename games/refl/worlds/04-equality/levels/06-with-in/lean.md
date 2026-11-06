---
title: "cases e : …"
learning_goals:
  - "`cases e : t with` also remembers `e : t = result` in each branch."
  - "Boolean tests must be remembered to be reasoned about."
hints:
  - text: "`unfold f`, then `cases e : isZero n with`, and cases `| true => sorry` and `| false => sorry`. The `e :` is what keeps the fact you'll need."
  - text: "In the `true` case `e : n.isZero = true`. `isZero_true e` turns that into `n = zero`, which `h` refutes. So this case is impossible. The `false` case computes."
  - text: "`| true => exact absurd (isZero_true e) h`, and `| false => rfl`."
example_explanation: |-
  1. Split on the Boolean test.
  2. `e :` keeps evidence relating the original expression to the selected Boolean.
  3. In the `true` case `isZero_true` contradicts `h`, and in the `false` case `rfl` finishes. In the exercise the target also mentions a function defined by the test.
---
Last level, you split on a `Decidable`, which carries its evidence inside. A test that returns a boolean doesn't: a plain `true` can't tell you why it's true. If you split on it, you
learn which branch you're in, but you've no way to use that fact in a proof.

`cases e : t with` solves this. It splits on `t` as before, and in each branch it also gives you an equation `e` saying what `t` turned out to be.

```lean
def f (n : MyNat) : MyNat :=
  match isZero n with
  | true => 1
  | false => n
```

`isZero` is a test that returns a `Bool`. Prove that `f n = n` whenever `n` isn't zero.

Unfold `f`, write the `cases` as you did last level, adding `e :`, and give it one case each for `true` and `false`. Then press **Goal** and read what's above the line in each. In the
`false` case, the `match` can compute to `n`. In the `true` case you're in an impossible situation: `n` isn't zero, yet the test says it is.

To turn the test's result into a real equation, the game's library gives you this lemma:

```lean
theorem isZero_true : ∀ {n : MyNat}, isZero n = true → n = zero
```

<!-- @conclusion -->
You'll see `cases h : e` and `match h : e with` wherever code branches on a boolean test and a proof has to follow it.
