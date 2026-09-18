---
example_explanation: |-
  1. Split the recursive input into `zero` and `suc n`.
  2. The base equation computes.
  3. In the step, `example n` proves the smaller equation; `cong suc` lifts it. Transfer the choice of recursion variable and the lifted induction hypothesis to the exercise.
hints:
- hidden: false
  text: Moving a successor across addition follows recursion on the right argument.
- hidden: true
  text: Split `y`, the argument that makes addition compute. In the step, both sides
    have an outer successor.
- hidden: true
  text: Use `suc-+ x (suc y) = cong suc …` with a smaller recursive call.
learning_goals:
- Induction on the argument the definition recurses on.
- '`suc x + y ≡ suc (x + y)`: the mirror image of the defining clause `x + suc y =
  suc (x + y)`.'
title: suc-+
---
Moving a successor across addition follows recursion on the right argument.

The definition of `_+_` says what `x + suc y` is. This lemma says what
`suc x + y` is, and needs induction on `y` because that is the argument
that computes.

Same recipe as `zero-+`: case split, `refl`, `cong suc` of the inductive
call.


<!-- @conclusion -->

NNG4 calls this `succ_add`. With `zero-+` and `suc-+` you can now prove
commutativity.
