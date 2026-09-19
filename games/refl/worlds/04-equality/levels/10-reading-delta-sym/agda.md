---
title: "Reading: δ is symmetric (Matrix.lagda)"
learning_goals:
  - "`with` on two scrutinees gives a grid of cases."
  - "Contradictory cases are closed with `⊥-elim` and `sym`."
hints:
  - text: "`with i ≟ j | j ≟ i` and four cases. The two agreeing cases are `refl`; in the two disagreeing ones, one decision refutes the other via `sym`."
  - text: "`... | yes p | no ¬q = ⊥-elim (¬q (sym p))` and symmetrically."
    hidden: true
example_explanation: |-
  1. `δ i i` is defined by `with i ≟ i`, so the proof must inspect the same decision: `with i ≟ i`.
  2. In the `yes` branch `δ i i` computes to `1`: `refl`.
  3. The `no` branch is impossible (`i ≡ i` holds by `refl`), so eliminate it with `⊥-elim`.
  For the exercise, inspect both `i ≟ j` and `j ≟ i` in one `with`; two of the four cases are `refl`, the other two contradict each other via `sym`.
---
`Matrix.lagda:305`:

```agda
diag-sym w i j with i ≟ j
```

Here is its core: the Kronecker delta is symmetric. Abstract both
decisions at once (`with i ≟ j | j ≟ i`) and handle the four cases.

<!-- @conclusion -->
**Equality World complete.** You can now read every `with`, `rewrite`,
`inspect`, `subst₂` and `Decidable⇒UIP` in the three target
repositories. Order World is next: `_≤_` as data, and the Boolean
reflection idiom (`T`, `≤ᵇ⇒≤`) that `Decoding.agda` is built on.
