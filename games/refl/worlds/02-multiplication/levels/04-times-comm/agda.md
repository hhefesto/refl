---
title: "*-comm"
learning_goals:
  - "The same proof skeleton as `+-comm`, with `zero-*` and `suc-*` in place of `zero-+` and `suc-+`."
hints:
  - text: "Base: `x * zero ≡ zero * x` is `sym (zero-* x)`. Step: `x * y + x ≡ suc y * x`; use the hypothesis under `cong (_+ x)`, then `suc-* y x` backwards."
  - text: "`*-comm x (suc y) = trans (cong (_+ x) (*-comm x y)) (sym (suc-* y x))`."
    hidden: true
example_explanation: |-
  1. Normalise: `x * zero` computes to `zero` (recursion on the second argument), but `zero * x` is stuck.
  2. `zero-* x` is exactly the stuck side rewritten to `zero`, so it is the whole proof.
  The exercise generalises this: split `y`; the zero case is this example, the `suc` case uses `suc-*` and the induction hypothesis.
---
Look back at your `+-comm` proof: this one has the same shape.

<!-- @conclusion -->
The two commutativity proofs are the same *program* over different
operations. World 8 (records) turns that observation into a structure: a
commutative semiring proved once, instantiated many times.
