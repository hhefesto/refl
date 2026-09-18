---
example_explanation: |-
  1. Split on the disjunction.
  2. Its left payload is impossible, so use `()` with no right-hand side.
  3. The right payload is truth, whose constructor is `tt`. These two cases demonstrate the separate obligations in the exercise.
hints:
- hidden: false
  text: Falsity has no constructors; truth has exactly one.
- hidden: true
  text: Split the impossible argument of the first definition. The second definition
    needs the constructor of truth.
- hidden: true
  text: An absurd clause has no `= …`; the other definition does have a right-hand
    side.
learning_goals:
- '`⊥` has no constructors; case splitting on it yields the absurd clause `()`.'
- '`⊤` has exactly one proof, `tt`.'
title: From falsity, anything
---
Falsity has no constructors; truth has exactly one.

Two lemmas. `ex-falso : ⊥ → A`: case split on the hypothesis of type `⊥`;
since `⊥` has no constructors Agda produces the **absurd pattern** `()`
and the clause needs no right-hand side.

`trivial : ⊤`: the one proof is `tt`.


<!-- @conclusion -->

`⊥-elim` in `Refl.Logic` is exactly `ex-falso`. You will use it whenever a
hypothesis is impossible: `⊥-elim (¬p refl)`.
