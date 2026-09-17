---
id: exists
index: 7
title: "There exists"
learning_goals:
  - "`∃ P` (a `Σ` type) is a witness paired with a proof about it."
  - "The witness is data: you choose it."
unlocks:
  syntax:
    - name: "Σ / ∃"
      doc: "sigma.md"
hints:
  - text: "Choose the witness first: which `n` makes `n + 1 ≡ 3`? Then the proof is `refl`."
  - text: "`witness = 2 , refl`."
    hidden: true
---
`∃ (λ n → n + 1 ≡ 3)` is the type of pairs `(n , proof)`. Unlike
classical existence, the pair *contains* the number. This is what the
study notes call "constructive proofs as data": Timely Computation's
`stable` signals literally carry their interval.

<!-- @conclusion -->
A `Σ` type generalises `×`: the second component's *type* may mention the
first component. `A × B` is `Σ A (λ _ → B)`.
