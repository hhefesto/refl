---
example_explanation: |-
  1. `¬ (1 ≡ 2)` unfolds to `1 ≡ 2 → ⊥`, a function type.
  2. `1` is `suc zero` and `2` is `suc (suc zero)`. Agda strips the shared `suc` and compares `zero` with `suc zero`, which are different constructors.
  3. So the argument can't exist, and `λ ()` is the whole function. The exercise works the same way with a variable inside the `suc`.
---
