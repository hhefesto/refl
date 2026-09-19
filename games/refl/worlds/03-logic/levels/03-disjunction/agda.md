---
title: "Or is a choice"
learning_goals:
  - "`A ⊎ B` has two constructors; a proof records which side."
  - "Case split on a sum to handle both."
hints:
  - text: "Case split on `s`: two clauses, `inj₁ a` and `inj₂ b`."
  - text: "`⊎-comm (inj₁ a) = inj₂ a`; `⊎-comm (inj₂ b) = inj₁ b`."
    hidden: true
example_explanation: |-
  1. A disjunction contains a tag and a payload.
  2. Handle both tags, recovering an `A` in each branch.
  3. Return the payload. The exercise instead inserts it into the target's appropriate constructor.
---
Disjunction is a data type with two constructors. Unlike a classical *or*,
a proof says *which* side holds — which is why `P ∪ Q` in the language
paper is a type of *parses*, not a yes/no.

<!-- @conclusion -->
Notice the asymmetry with `×`: a pair is *eliminated* by projections and
*built* by one constructor; a sum is *built* by two constructors and
*eliminated* by case analysis.
