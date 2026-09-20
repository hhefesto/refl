---
example_explanation: |-
  This example asks about `3 + 1`, a different sum, so the endpoints meet
  by a different computation. Walk down from the left:

  ```text
  3 + 1
  → 3 + suc zero
  → suc (3 + zero)
  → suc 3
  ```

  The first line is notation, the second uses the successor rule, the third
  the zero rule. Walking down from the right takes one step: `4` is `suc 3`.
  Both sides read `suc 3`, so the chain needs only that one middle line. For
  the exercise, find where its own two endpoints land before filling the holes.
---
