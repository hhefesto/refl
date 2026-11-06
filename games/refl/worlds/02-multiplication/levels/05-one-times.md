---
id: one-times
index: 5
title: "one-*"
learning_goals:
  - "Chaining two inventory lemmas."
unlocks:
  lemmas:
    - name: "one-*"
      bend2: "Multiplication.one_mul"
      agda: "one-*"
      lean: "one_mul"
hints:
  - text: "`x * 1 ≡ x` is in your inventory as `*-one`. Which lemma lets you turn `1 * x` into `x * 1`?"
  - text: "`*-comm 1 x : 1 * x ≡ x * 1`. Chain it with `*-one x` using `trans`."
  - text: "`one-* x = trans (*-comm 1 x) (*-one x)`."
---
`1 * x ≡ x`. Here `x` is on the right, where multiplication looks, so `1 * x` is stuck.
You could prove this by induction, the way you proved `zero-*`.

But you don't have to. Induction is how you prove a *new* fact about a recursive
definition, and this isn't really a new fact: you've already shown that `x * 1` is `x`,
and you've just shown that the order of a product doesn't matter. Put those together.

This is the first proof in the world with no case split at all, just lemmas in a row.
Put `trans` in the box and press **Refine** to get a hole for each. Think about what the
middle term has to be.

<!-- @conclusion -->
When a lemma follows from others, it doesn't need a case split. Reach for `trans`
first, and for induction only when your lemmas run out.
