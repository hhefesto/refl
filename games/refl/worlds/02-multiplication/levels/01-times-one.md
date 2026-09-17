---
id: times-one
index: 1
title: "*-one"
learning_goals:
  - "Unfold a definition by hand: `x * 1` is `x * zero + x`, which is `zero + x`."
  - "Reuse `zero-+`."
unlocks:
  lemmas:
    - name: "*-one"
      agda: "*-one"
      lean: "mul_one"
hints:
  - text: "Normalise `x * 1`. It becomes `zero + x`, which is not `x` by computation — but you have a lemma for it."
  - text: "`*-one x = zero-+ x`."
    hidden: true
---
`1` is `suc zero`, so `x * 1 = x * zero + x = zero + x`. One inventory
lemma finishes it. No induction.

<!-- @conclusion -->
`x * zero ≡ zero` is `refl` and never needs a lemma, just like `x + zero`.
