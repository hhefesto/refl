---
example_explanation: |-
  1. Split the number as far as the statement needs: `zero`, `suc zero` and `suc (suc n)`.
  2. Only `suc zero` equals `1`, with evidence `refl`.
  3. Every other number differs from `1` by a constructor, so its refutation is `λ ()`. The exercise compares two numbers, so it also needs a recursive decision.
---
