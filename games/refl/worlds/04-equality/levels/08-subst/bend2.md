---
title: "subst and transport"
learning_goals:
  - "`Refl.subst` carries a proof of `P(x)` to a proof of `P(y)` along `x == y`."
  - "Choosing the motive `P` is the whole game."
hints:
  - text: "You hold `p : {x == y : Nat}` and want `{x == z : Nat}`. Think of `p` as `P(y)`, and the goal as `P(z)`, for a `P` that leaves the `x ==` alone and varies what comes after it. You move along `q : {y == z : Nat}`."
  - text: "The motive is `w => {x == w : Nat}`. Its endpoints are `y` and `z`, the equation is `q`, and the proof you carry is `p`."
  - text: "`Refl.subst(Nat, w => {x == w : Nat}, y, z, q, p)`."
example_explanation: |-
  1. Choose the family `n => {Refl.add(n, 1n) == 5n : Nat}`.
  2. The hypothesis `h` is an inhabitant of this family at `a`.
  3. Carry it along `p` to the family at `b`. In the exercise, choose a family that varies the right side of an equality.
---
If two things are equal, whatever is true of one is true of the other. The library has a lemma that says so:

```
law subst:
  for -A: Type
  for -P: A -> Type
  for -x: A
  for -y: A
  for e: {x == y : A}
  for px: P(x)
  P(y)
```

`P` is a predicate, and it's called the **motive**: it says what's being carried across the equation. Given a proof that `x` equals `y`, and a proof of `P(x)`, you get a proof of `P(y)`.

Picking `P` is the whole art of using it. Here's a way to do it: write down the type you have and the type you want, and find what's the same in both. For example, to go from `{Refl.add(a, 1n) == 5n : Nat}` to `{Refl.add(b, 1n) == 5n : Nat}` along `a` equals `b`, what stays the same is everything but the `a`, so `P` is `n => {Refl.add(n, 1n) == 5n : Nat}`.

Now reprove `Equal.trans` this way, under the name `trans_`, without `Equal.trans` itself, which is forbidden here. You have `p` and `q`, and you owe `{x == z : Nat}`. What stays the same, and which equation moves you?

<!-- @conclusion -->
You've used a motive every time you wrote `%e : P`: `P` with its `_` is the same idea. Most of the skill is in seeing what stays fixed.
