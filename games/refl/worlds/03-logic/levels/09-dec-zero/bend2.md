---
learning_goals:
  - "`Refl.Dec<A>` is `Yes{a}` or `No{na}`: a decision *with evidence*."
  - "Writing a decision means proving something in every case."
hints:
  - text: "`match n:`. The goals are `Refl.Dec<{0n == 0n : Nat}>` and `Refl.Dec<{1n+p == 0n : Nat}>`. Which of these is true?"
  - text: "`Refl.Yes{…}` wants a proof of the equation, and `Refl.No{…}` wants a function from the equation to `Empty`. In the second case your lemma has the sides the other way round, so flip `e` with `Equal.sym`."
  - text: "`case 0n:` is `Refl.Yes{{==}}`, and `case 1n+p:` is `Refl.No{e => Logic.zero_ne_succ(p, Equal.sym(Nat, 1n+p, 0n, e))}`."
example_explanation: |-
  1. Decide the answer yourself: `0n` and `1n` are different.
  2. Saying no requires a refutation, a function from the equation to `Empty`.
  3. `Logic.zero_ne_succ(0n)` is exactly that. In the exercise the answer depends on `n`, so it starts with a `match`.
---
A function returning a boolean can tell you an answer, but it can't tell you why. Nothing stops it being wrong. Here's something better, from the game's library:

```
type Dec<-A: Type> is Type:
  Yes{proof: A}
  No{refute: A -> Empty}
```

A value of type `Dec<A>` is a decision about the proposition `A`, and it comes with evidence. Saying `Yes` requires a proof of `A`, and saying `No` requires a refutation of `A`. So a program of this type can't give you the wrong answer: the type won't let it. They're written `Refl.Yes{…}` and `Refl.No{…}` here, because they come from the `Refl` module.

Start with a simple decision: is this number zero? You can't answer until you know what `n` is, so `match` on it. In each case the answer is then obvious to you. Your job is to convince Bend, and you've just learned what the evidence looks like when the answer is no.

<!-- @conclusion -->
Writing a decision procedure means writing a proof for every case. That's the difference between `Dec` and a boolean, and the next level needs it: deciding whether *any* two numbers are equal.
