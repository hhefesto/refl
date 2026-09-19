---
title: "*-one"
learning_goals:
  - "Unfold a definition by hand: `x * 1` is `x * zero + x`, which is `zero + x`."
  - "Reuse `zero-+`."
hints:
  - text: "Normalise `x * 1`. It becomes `zero + x`, which is not `x` by computation — but you have a lemma for it."
  - text: "`*-one x = zero-+ x`."
    hidden: true
example_explanation: |-
  1. Unfold: `x * 2` is `x * suc 1`, which computes to `x * 1 + x`, then to `(x * zero + x) + x`, then to `(zero + x) + x`.
  2. `zero + x` is stuck, but `zero-+ x` proves it equals `x`; `cong (λ n → n + x)` places that under the outer `+ x`.
  For the exercise, `x * 1` unfolds one step less, to `zero + x`, so `zero-+` alone finishes it.
---
`1` is `suc zero`, so `x * 1 = x * zero + x = zero + x`. One inventory
lemma finishes it. No induction.

<!-- @conclusion -->
`x * zero ≡ zero` is `refl` and never needs a lemma, just like `x + zero`.
