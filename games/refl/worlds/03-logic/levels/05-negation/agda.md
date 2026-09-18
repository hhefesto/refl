---
example_explanation: |-
  1. Expand double negation to `(A → ⊥) → ⊥`.
  2. Introduce the alleged refutation `notA`.
  3. Apply it to the given `a`. In the exercise build the refuted value using the additional function hypothesis.
hints:
- hidden: false
  text: Negation is a function that turns evidence into a contradiction.
- hidden: true
  text: Introduce the refutation and an `A`. The function hypothesis turns that `A`
    into the refuted type.
- hidden: true
  text: Start `contraposition f notB a = notB (…)`.
learning_goals:
- '`¬ A` unfolds to `A → ⊥`, so a proof of `¬ A` takes an `A`.'
- Contraposition without classical logic.
title: Negation is a function to ⊥
---
Negation is a function that turns evidence into a contradiction.

`¬ A` is defined as `A → ⊥`. So a proof of `¬ A` is a function, and using
a negation means *applying* it to get a `⊥`. Refine with an empty box
repeatedly to introduce the arguments one by one.


<!-- @conclusion -->

Constructively, `¬ ¬ A → A` is *not* provable in general, but
`A → ¬ ¬ A` and contraposition are. Agda is a constructive logic: a proof
is a program, so it cannot conjure an `A` out of the absence of a
refutation.
