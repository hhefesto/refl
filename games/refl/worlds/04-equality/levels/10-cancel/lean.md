---
learning_goals:
  - "A proof of an equation is a value, and two such values can be compared."
  - "In Lean, any two proofs of the same proposition are equal by `rfl`."
hints:
  - text: "The goal is an equation between proofs. Try the method you've used all world: `cases e`, then look at the goal."
  - text: "`rfl` closes it. Now try removing the `cases e`: `rfl` alone works too. Why?"
example_explanation: |-
  1. `p` may be matched against `rfl`.
  2. Then `Eq.trans rfl rfl` is a proof of `x = x`, and so is `rfl`.
  3. In Lean, those are the same by proof irrelevance, so `rfl` proves it. It also works without the `cases`.
---
The next three levels work up to one theorem, so let's start with the question it answers.

A proof of `x = y` is a value of a type. So it makes sense to ask whether two *proofs* are equal: `p = q`, for `p q : x = y`. Are any two proofs of the same equation the same proof?

In some provers that's a real question, and these three levels answer it there. In Lean, the answer is built in. `x = y` lives in `Prop`, and Lean has a rule called **proof irrelevance**: any two proofs of the same `Prop` are definitionally equal. Lean doesn't look inside them
at all, which is why **Goal** prints a proof as `⋯`.

This level's statement is an equation between proofs:

```lean
theorem trans_symm {A : Type} {x y : A} (e : x = y) : Eq.trans (Eq.symm e) e = rfl
```

Going along `e` backwards, and then forwards again, gets you nowhere. Try matching on `e` first, as you've done all world. Then see whether you really needed to.

<!-- @conclusion -->
A proof and its inverse cancel, as in a group. In Agda, this takes a real proof, by matching on the equation. In Lean, it's one word, because the two sides aren't even considered different.
