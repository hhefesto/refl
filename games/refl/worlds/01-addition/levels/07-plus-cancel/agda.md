---
example_explanation: |-
  1. Split the number of wrappers.
  2. With no wrappers the hypothesis already has the target type.
  3. Otherwise strip one constructor and recurse on the smaller hypothesis. Cancellation of addition uses the same decreasing measure.
hints:
- hidden: false
  text: Cancellation removes the same number of successors from an equality.
- hidden: true
  text: Split `z`. In the step, the hypothesis has two successor endpoints, so strip
    them before recursing.
- hidden: true
  text: Use `+-cancelʳ x y (suc z) h = +-cancelʳ x y z …`.
learning_goals:
- A hypothesis that changes shape as you case split.
- The induction hypothesis is used on a *smaller* hypothesis, obtained with `suc-injective`.
title: +-cancelʳ
---
Cancellation removes the same number of successors from an equality.

Cancellation: from `x + z ≡ y + z` conclude `x ≡ y`. The hypothesis `h`
is an argument, and after a case split on `z` its type computes along with
the goal. Ask for the goal in each clause and read the context carefully.


<!-- @conclusion -->

This is the pattern for every "cancellation" lemma: the inductive call
takes a *smaller hypothesis* built from the current one.
