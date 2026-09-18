---
example_explanation: |-
  1. Unfold: `x * 2` is `x * suc 1`, which computes to `x * 1 + x`, then to `(x * zero + x) + x`, then to `(zero + x) + x`.
  2. `zero + x` is stuck, but `zero-+ x` proves it equals `x`; `cong (λ n → n + x)` places that under the outer `+ x`.
  For the exercise, `x * 1` unfolds one step less, to `zero + x`, so `zero-+` alone finishes it.
---
