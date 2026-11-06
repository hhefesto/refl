---
title: "Equations between proofs"
learning_goals:
  - "A proof of an equation is a value, and two such values can be compared."
  - "`Equal.trans(…, Equal.sym(…, e), e)` is `{==}`: a proof cancels against its inverse."
hints:
  - text: "The goal is an equation between proofs, and it mentions `e`. So use last level's form: `%E@e : …`, with the goal as your motive, `_` for `y` and `E` for `e`."
  - text: "The motive is `{Equal.trans(A, _, x, _, Equal.sym(A, x, _, E), E) == {==} : {_ == _ : A}}`. After it, the goal is `{{==} == {==} : {x == x : A}}`."
  - text: "`%E@e : {Equal.trans(A, _, x, _, Equal.sym(A, x, _, E), E) == {==} : {_ == _ : A}}`, then `{==}`."
example_explanation: |-
  1. Mark `y` and `p` in the goal with `_` and `E`.
  2. Then `Equal.trans(A, x, x, x, {==}, {==})` computes to `{==}`.
  3. `{==}` proves it. Try the same on the exercise, where the composite goes backwards and then forwards.
---
The next three levels work up to one theorem, so let's start with the question it answers.

A proof of `x` equals `y` is a value, an ordinary value of a type. So it makes sense to ask whether two *proofs* are equal. You can write that down: `{p == q : {x == y : A}}`. Are any two proofs of the same equation the same proof?

You might think that's obvious, as there's only one `{==}`. But it isn't provable in general: to use J you need an endpoint free to move, and if `p : {x == x : A}`, then the endpoints are already tied together.

So let's see what *can* be proved. This level's statement is an equation between proofs: going along `e` backwards, and then forwards again, gets you nowhere. The endpoints here are two separate variables, so J applies. **Goal** prints the composite with `Equal.trans` unfolded, into two rewrites. It's stuck until it knows what `e` is.

<!-- @conclusion -->
A proof and its inverse cancel, as in a group. That's a real fact about proofs, and the next level uses it.
