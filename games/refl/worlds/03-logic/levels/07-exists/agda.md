---
example_explanation: |-
  1. Choose a witness, here `4`.
  2. Substitute it into the predicate, obtaining `4 + 2 ≡ 6`.
  3. Prove the computed equality with `refl`. Choose a different witness for the exercise's equation.
hints:
- hidden: false
  text: An existence proof contains a witness and evidence that it satisfies the predicate.
- hidden: true
  text: Choose the number before proving its equation; the second component's type
    then becomes concrete.
- hidden: true
  text: Use the pair shape `… , …`, with a numeral in the first position.
learning_goals:
- '`∃ P` (a `Σ` type) is a witness paired with a proof about it.'
- 'The witness is data: you choose it.'
title: There exists
---
An existence proof contains a witness and evidence that it satisfies the predicate.

`∃ (λ n → n + 1 ≡ 3)` is the type of pairs `(n , proof)`. Unlike
classical existence, the pair *contains* the number. This is what the
study notes call "constructive proofs as data": Timely Computation's
`stable` signals literally carry their interval.


<!-- @conclusion -->

A `Σ` type generalises `×`: the second component's *type* may mention the
first component. `A × B` is `Σ A (λ _ → B)`.
