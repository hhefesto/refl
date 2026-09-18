---
example_explanation: |-
  1. Match the nested pair to name its components.
  2. Read the target's nesting.
  3. Reassemble with `,`. Transfer the decomposition/reassembly technique to the exercise's different arrangement.
hints:
- hidden: false
  text: Conjunction carries evidence for both propositions as a pair.
- hidden: true
  text: Split `p` into its two components, then read the order required by the target.
- hidden: true
  text: Start `×-comm (a , b) = … , …`.
learning_goals:
- '`A × B` is a record with fields `proj₁ : A` and `proj₂ : B`; `a , b` builds one.'
- Case split on a pair to name its parts.
title: And is a pair
---
Conjunction carries evidence for both propositions as a pair.

A proof of `A × B` is a pair. The constructor is `_,_` (mixfix: `a , b`),
the projections are `proj₁`, `proj₂`.


<!-- @conclusion -->

`_×_` is a *record*; case splitting on a record value gives its constructor
pattern. Records are World 8's subject; here they are just pairs.
