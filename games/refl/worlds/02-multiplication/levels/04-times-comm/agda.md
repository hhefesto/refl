---
example_explanation: |-
  1. Normalise: `x * zero` computes to `zero` (recursion on the second argument), but `zero * x` is stuck.
  2. `zero-* x` is exactly the stuck side rewritten to `zero`, so it is the whole proof.
  The exercise generalises this: split `y`; the zero case is this example, the `suc` case uses `suc-*` and the induction hypothesis.
---
