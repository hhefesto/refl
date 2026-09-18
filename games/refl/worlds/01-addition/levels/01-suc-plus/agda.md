---
example_explanation: |-
  1. `_+_` recurses on its second argument, so `y` is the variable to split: Case split on `y`.
  2. `y = zero`: both sides compute to `suc x`, so `refl`.
  3. `y = suc y`: both sides compute to `suc (…)` of the smaller statement; `cong suc (example x y)` lifts the recursive call.
  The exercise has the same shape: split the second argument, `refl` at zero, `cong suc` of the recursive call at `suc`.
---
