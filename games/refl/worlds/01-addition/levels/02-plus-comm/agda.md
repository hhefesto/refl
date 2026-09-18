---
example_explanation: |-
  1. Normalise both sides: `x + 1` computes to `suc x` (recursion on the second argument), but `1 + x` is stuck.
  2. So work on the stuck side: `suc-+ zero x : 1 + x ≡ suc (zero + x)`, then `zero-+ x` inside `suc`.
  3. Chain with `trans`, and flip with `sym` because the goal wants `x + 1` on the left.
  For the exercise, split `y`: the zero case is this idea with `zero-+`, the `suc` case uses `suc-+` and the induction hypothesis under `cong suc`.
---
