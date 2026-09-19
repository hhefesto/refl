---
example_explanation: |-
  1. Three variables, but `_+_` only computes on its second argument, and `z` is the innermost second argument on both sides: split `z`.
  2. `z = zero`: `y + zero` and `(x + y) + zero` both compute away; `refl`.
  3. `z = suc z`: both sides become `suc (…)`, so `cong suc` of the recursive call.
  The exercise is the mirror image: same split, same two clauses.
---
