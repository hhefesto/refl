---
example_explanation: |-
  1. `2 * x` is `suc 1 * x`, which is stuck; `suc-* 1 x` rewrites it to `1 * x + x`.
  2. Inside, `one-* x` turns `1 * x` into `x`; `cong (λ n → n + x)` applies it under `+ x`.
  3. `trans` chains the two steps.
  For the exercise, `1 * x` is `suc zero * x`: apply `suc-*` once and then `zero-*` inside, the same two-step shape.
---
