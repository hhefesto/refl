---
title: "one_mul"
learning_goals:
  - "Chaining two inventory lemmas."
hints:
  - text: "`Refl.mul(x, 1n) == x` is in your inventory as `Multiplication.mul_one`. Which lemma turns `Refl.mul(1n, x)` into `Refl.mul(x, 1n)`?"
  - text: "`Multiplication.mul_comm(1n, x)`. Chain the two with `Equal.trans`, with `Refl.mul(x, 1n)` as the middle term."
  - text: "`Equal.trans(Nat, Refl.mul(1n, x), Refl.mul(x, 1n), x, Multiplication.mul_comm(1n, x), Multiplication.mul_one(x))`."
example_explanation: |-
  1. The outer `Refl.add(_, 0n)` computes away.
  2. `mul_comm(1n, x)` changes `Refl.mul(1n, x)` into `Refl.mul(x, 1n)`.
  3. `mul_one(x)` removes the multiplication by one, and `Equal.trans` connects the steps. Start by asking which simplifications compute and which need a lemma.
---
`Refl.mul(1n, x) == x`. Here `x` is on the right, where multiplication looks, so the left side is stuck. You could prove this by induction, the way you proved `zero_mul`.

But you don't have to. Induction is how you prove a *new* fact about a recursive definition, and this isn't really a new fact: you've already shown that `Refl.mul(x, 1n)` is `x`, and you've just shown that the order of a product doesn't matter. Put those together.

This is the first proof in the world with no `match` at all, just lemmas in a row. Think about what the middle term of the `Equal.trans` has to be.

<!-- @conclusion -->
When a lemma follows from others, it doesn't need an induction. Reach for your lemmas first, and for `match` only when they run out.
