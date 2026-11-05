---
example_explanation: |-
  1. `δ i i` is defined by `with i ≟ i`, so the proof must inspect the same decision: `with i ≟ i`.
  2. In the `yes` branch `δ i i` computes to `1`: `refl`.
  3. The `no` branch is impossible (`i ≡ i` holds by `refl`), so eliminate it with `⊥-elim`.
  For the exercise, inspect both `i ≟ j` and `j ≟ i` in one `with`; two of the four cases are `refl`, the other two contradict each other via `sym`.
---
