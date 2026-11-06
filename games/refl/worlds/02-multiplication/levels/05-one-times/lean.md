---
title: "one_mul"
learning_goals:
  - "Chaining two inventory lemmas."
hints:
  - text: "`x * 1 = x` is in your inventory as `mul_one`. Which lemma lets you turn `1 * x` into `x * 1`?"
  - text: "`rw [mul_comm]` turns the goal into `x * 1 = x`."
  - text: "`rw [mul_comm]` on one line and `exact mul_one x` on the next."
example_explanation: |-
  1. The outer `+ 0` computes away by the definition of addition.
  2. `mul_comm 1 x` changes `1 * x` into `x * 1`.
  3. `mul_one x` removes the multiplication by one, and `Eq.trans` connects the steps. Start by asking which simplifications compute and which need a lemma.
---
`1 * x = x`. Here `x` is on the right, where multiplication looks, so `1 * x` is stuck. You could prove this by
induction, the way you proved `zero_mul`.

But you don't have to. Induction is how you prove a *new* fact about a recursive definition, and this isn't really
a new fact: you've already shown that `x * 1` is `x`, and you've just shown that the order of a product doesn't
matter. Put those together.

This is the first proof in the world with no induction at all, just lemmas in a row. A `rw` can use a lemma
without being told its arguments: it looks for the first place the pattern fits. Press **Goal** after each line
to see where it landed.

<!-- @conclusion -->
When a lemma follows from others, it doesn't need an induction. Reach for your lemmas first, and for induction only
when they run out.
