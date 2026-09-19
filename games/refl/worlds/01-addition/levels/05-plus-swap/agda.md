---
example_explanation: |-
  1. Compare the two sides: they differ only inside the left summand, `x + y` versus `y + x`.
  2. `+-comm x y` proves that inner equation; `cong` with the function `λ n → n + z` transports it to the whole sum.
  For the exercise, first move the outer structure with `+-assoc` (twice) so that the difference is again a single `+-comm` deep inside, then `cong` it in.
---
