---
example_explanation: |-
  1. Split on `z`, the argument on which the inner addition computes. At zero, the right side contains `0 + x`; use `zero-+ x` backwards under `x * y +_`.
  2. At `suc z`, unfold multiplication. Apply the recursive proof under the new outer `+ x` using `cong`.
  3. The resulting three summands are associated differently; `+-assoc` finishes the step.
  This example proves its own strengthened statement recursively, using only the addition lemmas already earned.
---
