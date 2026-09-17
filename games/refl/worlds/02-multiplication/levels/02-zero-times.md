---
id: zero-times
index: 2
title: "zero-*"
learning_goals:
  - "Induction on the right argument of `*`."
unlocks:
  lemmas:
    - name: "zero-*"
      agda: "zero-*"
      lean: "zero_mul"
hints:
  - text: "Case split on `x`. The step goal is `zero * x + zero ≡ zero`, and `_+ zero` computes away."
  - text: "`zero-* zero = refl`; `zero-* (suc x) = zero-* x`."
    hidden: true
---
The mirror of `x * zero ≡ zero`, by induction.

<!-- @conclusion -->
Compare with `sumTo-zero`: same proof, because a product is a repeated sum.
