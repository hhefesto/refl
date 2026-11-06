---
title: "add_right_cancel"
learning_goals:
  - "A hypothesis that changes shape during an induction."
  - "The induction hypothesis takes a *smaller* hypothesis, obtained with `succ_inj`."
hints:
  - text: "`induction z with`. In the `zero` case, read what's above the line: `h : x + zero = y + zero`, which computes to the goal."
  - text: "In the `succ` case `ih : x + z = y + z → x = y` and `h : x + z.succ = y + z.succ`. That computes to `succ (x + z) = succ (y + z)`, which is what `succ_inj` wants."
  - text: "`| zero => exact h`, and `| succ z ih => exact ih (succ_inj h)`."
example_explanation: |-
  1. Induct on the number of wrappers.
  2. With no wrappers the hypothesis already has the target type.
  3. Otherwise strip one constructor and use `ih` on the smaller hypothesis. Cancellation of addition uses the same decreasing measure.
---
Cancellation: from `x + z = y + z` conclude `x = y`. If two sums with the same right-hand term
are equal, the left-hand terms were too.

This proof has a surprise. So far, induction has changed the *goal*. Here the goal is `x = y`
in every case, because `z` isn't in it. What changes is the hypothesis: `h` mentions `z`, so
`induction z` carries `h` along with it.

So this time read **above the line**. Induct on the variable that appears in `h`, and look at
what `h` and `ih` have become. Notice that `ih` is now an implication: it wants a proof for the
smaller `z` before it gives you `x = y`.

You don't have that proof yet. You have something very close to it, and you proved the lemma
that closes the gap in the previous level.

<!-- @conclusion -->
This is the pattern for every "cancellation" lemma: the induction hypothesis takes a *smaller
hypothesis* built from the current one. Induction isn't only about making the goal smaller.
Sometimes it's the facts you hold that shrink.
