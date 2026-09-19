---
example_explanation: |-
  1. Unfold `_^_`: `x ^ 1` is `x ^ suc zero`, which computes to `x ^ zero * x`, then to `1 * x`.
  2. `1 * x` is stuck (`_*_` recurses on its second argument), and `one-* x` is exactly that equation.
  For the exercise, `x ^ 2` unfolds one step further, to `(1 * x) * x`; rewrite the inner `1 * x` with `one-*` under `cong (λ n → n * x)`.
---
