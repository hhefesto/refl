---
title: "Eq.subst and transport"
learning_goals:
  - "`Eq.subst p : P x → P y` transports along `p : x = y`."
  - "Choosing the motive is the whole game."
hints:
  - text: "You hold `p : x = y` and want `x = z`. Think of `p` as `P y`, and the goal as `P z`, for a `P` that leaves the `x =` alone and varies what comes after it. You move along `q : y = z`."
  - text: "The motive is `fun w => x = w`. Name it with `(motive := …)`."
  - text: "`exact Eq.subst (motive := fun w => x = w) q p`."
example_explanation: |-
  1. Choose the family `fun n => n + 1 = 5`.
  2. The hypothesis is an inhabitant of this family at `a`.
  3. Transport it along `p` to the family at `b`. In the exercise, choose a family that varies the right side of an equality.
---
If two things are equal, whatever is true of one is true of the other. That's `Eq.subst`:

```lean
theorem Eq.subst {motive : α → Prop} {a b : α} (h₁ : a = b) (h₂ : motive a) : motive b
```

`motive` is a predicate, saying what's being carried across the equation. Given a proof that `a = b`, and a proof of `motive a`, you get a proof of `motive b`. Lean often can't guess the motive from
the types, because many different predicates could fit, so you can tell it: `Eq.subst (motive := …) h₁ h₂`.

Picking the motive is the whole art here. Here's a way to do it: write down the type you have and the type you want, and find what's the same in both. For example, to go from `a + 1 = 5` to `b + 1 = 5`
along `a = b`, what stays the same is "`_ + 1 = 5`", so the motive is `fun n => n + 1 = 5`.

Now reprove `Eq.trans` this way, under the name `trans'`, without `cases`, `rw` or `Eq.trans`, which are forbidden here. You have `p : x = y` and `q : y = z`, and you owe `x = z`. What stays the same, and which equation
moves you?

<!-- @conclusion -->
Lean has a short spelling, `h ▸ e`, that tries to work the motive out for you. When it can't, you now know how to write it yourself. Most of the skill is in seeing what stays fixed.
