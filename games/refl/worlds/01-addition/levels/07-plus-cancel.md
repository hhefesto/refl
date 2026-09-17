---
id: plus-cancel
index: 7
title: "+-cancelʳ"
learning_goals:
  - "A hypothesis that changes shape as you case split."
  - "The induction hypothesis is used on a *smaller* hypothesis, obtained with `suc-injective`."
unlocks:
  lemmas:
    - name: "+-cancelʳ"
      agda: "+-cancelʳ"
      lean: "add_right_cancel"
      doc: "plus-cancel.md"
hints:
  - text: "Induction on `z`. In the base case `h : x + zero ≡ y + zero` is already `x ≡ y` up to computation."
  - text: "In the step case `h : suc (x + z) ≡ suc (y + z)`. Peel the `suc` with `suc-injective h`, then apply the induction hypothesis."
  - text: "`+-cancelʳ x y zero h = h` and `+-cancelʳ x y (suc z) h = +-cancelʳ x y z (suc-injective h)`."
    hidden: true
---
Cancellation: from `x + z ≡ y + z` conclude `x ≡ y`. The hypothesis `h`
is an argument, and after a case split on `z` its type computes along with
the goal. Ask for the goal in each clause and read the context carefully.

<!-- @conclusion -->
This is the pattern for every "cancellation" lemma: the inductive call
takes a *smaller hypothesis* built from the current one.
