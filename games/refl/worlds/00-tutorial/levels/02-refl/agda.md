---
example_explanation: |-
  The same one-word proof for a longer walk. Computing `20 + 22` applies
  `m + suc n = suc (m + n)` twenty-two times, so last level's chain would need
  dozens of rungs. `refl` does not grow with the computation: the checker does
  the extra work, and the proof stays one word.
---
