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
      bend2: "Addition.add_right_cancel"
      agda: "+-cancelʳ"
      lean: "add_right_cancel"
      doc: "plus-cancel.md"
hints:
  - text: "**Case split** on `z`. In the `zero` clause, ask for the **Goal** and read the context: what has `h` turned into?"
  - text: "In the `zero` clause `h : x ≡ y`, which is already the goal. In the `suc` clause `h : suc (x + z) ≡ suc (y + z)`. Peel off the `suc` with `suc-injective h`, and you have what a recursive call on the smaller `z` asks for."
  - text: "`+-cancelʳ x y zero h = h`, and `+-cancelʳ x y (suc z) h = +-cancelʳ x y z (suc-injective h)`."
---
Cancellation: from `x + z ≡ y + z` conclude `x ≡ y`. If two sums with the same
right-hand term are equal, the left-hand terms were too.

This proof has a surprise. So far, case splitting has changed the *goal*. Here the
goal is `x ≡ y` in every clause and never changes, because `z` isn't in it. What
changes is the hypothesis: `h` mentions `z`, so after the split its type computes
along with everything else.

So this time read the **context**, above the line. Case split on the variable that
appears in `h`, then look at what `h` has become in each clause.

Then think about the recursive call. `+-cancelʳ x y z` needs an argument too: a
proof for the smaller `z`. You don't have that yet. You have something very close
to it, and you proved the lemma that closes the gap in the previous level.

<!-- @conclusion -->
This is the pattern for every "cancellation" lemma: the recursive call takes a
*smaller hypothesis* built from the current one. Induction isn't only about making
the goal smaller. Sometimes it is the facts you hold that shrink.
