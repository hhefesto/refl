---
title: "add_right_cancel"
learning_goals:
  - "A hypothesis that changes shape as you match."
  - "The recursive call takes a *smaller* hypothesis, obtained with `succ_inj`."
hints:
  - text: "`match z:`. Press **Goal** in each case, and read `h` in the context."
  - text: "In the `0n` case `h` computes to the goal. In the `1n+p` case, `h : {1n+Refl.add(x, p) == 1n+Refl.add(y, p) : Nat}`. Peel off the `1n+` with `Addition.succ_inj`, and you have what a recursive call on the smaller `p` asks for."
  - text: "`case 0n:` is `h`. `case 1n+p:` is `add_right_cancel(x, y, p, Addition.succ_inj(Refl.add(x, p), Refl.add(y, p), h))`."
example_explanation: |-
  1. Match on the number of wrappers.
  2. With no wrappers, the hypothesis already has the target type.
  3. Otherwise strip one constructor and recurse on the smaller hypothesis. Cancellation of addition uses the same decreasing measure.
---
Cancellation: from `Refl.add(x, z) == Refl.add(y, z)` conclude `{x == y : Nat}`. If two sums with the same right-hand term are equal, the left-hand terms were too.

This proof has a surprise. So far, matching has changed the *goal*. Here the goal is `{x == y : Nat}` in every case, because `z` isn't in it. What changes is the hypothesis: `h` mentions `z`, so after the `match` its type computes along with everything else.

So this time read the **context**, in what **Goal** prints. Match on the variable that appears in `h`, then look at what `h` has become in each case.

Then think about the recursive call. `add_right_cancel(x, y, p, …)` needs a last argument: a proof for the smaller `p`. You don't have that yet. You have something very close to it, and you proved the lemma that closes the gap in the previous level.

<!-- @conclusion -->
This is the pattern for every "cancellation" lemma: the recursive call takes a *smaller hypothesis* built from the current one. Induction isn't only about making the goal smaller. Sometimes it's the facts you hold that shrink.
