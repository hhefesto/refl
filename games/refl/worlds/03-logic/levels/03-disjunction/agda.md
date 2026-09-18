---
example_explanation: |-
  1. A disjunction contains a tag and a payload.
  2. Handle both tags, recovering an `A` in each branch.
  3. Return the payload. The exercise instead inserts it into the target's appropriate constructor.
hints:
- hidden: false
  text: Disjunction carries one tagged piece of evidence, so elimination has two cases.
- hidden: true
  text: Split `s` into `inj₁ a` and `inj₂ b`. The target changes which side each payload
    belongs to.
- hidden: true
  text: Write one clause for each tag and choose the opposite injection.
learning_goals:
- '`A ⊎ B` has two constructors; a proof records which side.'
- Case split on a sum to handle both.
title: Or is a choice
---
Disjunction carries one tagged piece of evidence, so elimination has two cases.

Disjunction is a data type with two constructors. Unlike a classical *or*,
a proof says *which* side holds — which is why `P ∪ Q` in the language
paper is a type of *parses*, not a yes/no.


<!-- @conclusion -->

Notice the asymmetry with `×`: a pair is *eliminated* by projections and
*built* by one constructor; a sum is *built* by two constructors and
*eliminated* by case analysis.
