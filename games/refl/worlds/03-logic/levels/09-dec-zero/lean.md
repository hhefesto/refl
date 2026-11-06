---
learning_goals:
  - "`Decidable A` is `isTrue a` or `isFalse na`: a decision *with evidence*."
  - "Writing a decision means proving something in every case."
hints:
  - text: "`cases n with`, then `| zero => sorry` and `| succ n => sorry`. The goals are `Decidable (zero = zero)` and `Decidable (n.succ = zero)`. Which of these is true?"
  - text: "`isTrue` wants a proof of the equation, and `isFalse` wants a function from the equation to `False`. Inside a term, `by` starts tactics again."
  - text: "`| zero => exact isTrue rfl`, and `| succ n => exact isFalse (fun h => by cases h)`."
example_explanation: |-
  1. Decide the answer yourself: `1` and `2` are different.
  2. Saying no requires a refutation, a function from the equation to `False`.
  3. Lean can see that no such equation exists, so `by cases h` closes it. In the exercise the answer depends on `n`, so it starts with `cases`.
---
A function returning a boolean can tell you an answer, but it can't tell you why. Nothing stops it being wrong. Lean has something better:

```lean
class inductive Decidable (p : Prop) where
  | isFalse (h : ¬p) : Decidable p
  | isTrue (h : p) : Decidable p
```

A value of type `Decidable A` is a decision about the proposition `A`, and it comes with evidence. Saying `isTrue` requires a proof of `A`,
and saying `isFalse` requires a refutation of `A`. So a program of this type can't give you the wrong answer: the type won't let it.

Start with a simple decision: is this number zero? The statement is `Decidable (n = zero)`. Since this is *data*, not a proposition, the
statement says `def`, not `theorem`, but tactics still work.

You can't answer until you know what `n` is, so use `cases`. In each case the answer is then obvious to you. Your job is to convince Lean:
`isTrue` and `isFalse` each want their evidence. You've just learned what the evidence looks like when the answer is no. If you
want to use tactics in the middle of a term, write `by`.

<!-- @conclusion -->
Writing a decision procedure means writing a proof for every case. That's the difference between `Decidable` and a boolean, and the next level
needs it: deciding whether *any* two numbers are equal.
