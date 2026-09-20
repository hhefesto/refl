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
  the zero rule. Walking up from the right takes one step: `4` is `suc 3`.
  Both sides read `suc 3`, so the chain needs only that one middle line. The
  exercise starts you one step along each walk; work out the next step on each
  side before filling its hole.
---
