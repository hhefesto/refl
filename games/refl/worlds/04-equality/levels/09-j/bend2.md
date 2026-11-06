---
title: "A rewrite that sees the proof: J"
learning_goals:
  - "The eliminator J: to prove `P(y, p)` for every proof `p : {x == y : A}`, it suffices to prove `P(x, {==})`."
  - "`%E@p : P` names the equation so that the motive can mention it."
hints:
  - text: "Press **Goal**: `P(y, p)`, and `d : P(x, {==})` is in the context. A plain rewrite can only move `y`, but this motive also mentions `p`."
  - text: "Name the equation in the rewrite: `%E@p : P(_, E)`. `_` marks `y`, and `E` marks `p`. After that line the goal is `P(x, {==})`."
  - text: "`%E@p : P(_, E)`, then `d`."
example_explanation: |-
  1. A plain rewrite, marking `y`.
  2. Its two sides become the same, so `P(y)` becomes `P(x)`.
  3. Return the supplied evidence. For J, the motive also mentions the equality proof itself.
---
You have now rewritten with equations in many different ways. Time to state in one line what all of them have in common. That's **J**, and it looks hard only because of how much it says:

```
law J:
  for -A: Type
  for -x: A
  for -P: @y:A -> @e:{x == y : A} -> Type
  for d: P(x, {==})
  for -y: A
  for p: {x == y : A}
  P(y, p)
```

Compare it with `Refl.subst`, from the last level. `subst` carries a motive across an equation. So does J. The difference is that J's motive can also mention the *proof of the equation itself*, which is why `P` takes two arguments: an endpoint `y`, and a proof that `x` equals it.

In words: suppose you want to prove something about every `y` and every proof `p : {x == y : A}`. It's enough to prove it in the one case where `y` is `x` and `p` is `{==}`. Everything else follows.

Bend has this built in, as a form of rewrite. `%E@p : P` gives the equation the name `E` in the motive, so that `P` can talk about it as well as `_`.

<!-- @conclusion -->
`Equal.sym`, `Equal.trans`, `Equal.cong` and `Refl.subst` are all instances of J, each with its own motive. A note in Bend's own tests calls `%x@e : P` "the J axiom", and now you know why. It's also what makes the last theorem of this world interesting.
