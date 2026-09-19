---
title: "*-distribˡ-+"
learning_goals:
  - "Distributivity by induction, with `+-assoc` in the step."
hints:
  - text: "Induction on `z`. Step: left is `x * (y + z) + x`, right is `x * y + (x * z + x)`."
  - text: "Rewrite the left with the hypothesis under `cong (_+ x)`, then `+-assoc (x * y) (x * z) x`."
    hidden: true
example_explanation: |-
  1. Split on `z`, the argument on which the inner addition computes. At zero, the right side contains `0 + x`; use `zero-+ x` backwards under `x * y +_`.
  2. At `suc z`, unfold multiplication. Apply the recursive proof under the new outer `+ x` using `cong`.
  3. The resulting three summands are associated differently; `+-assoc` finishes the step.
  This example proves its own strengthened statement recursively, using only the addition lemmas already earned.
---
`x * (y + z) ≡ x * y + x * z`. The superscript `ˡ` says the factor is on
the left; type it as `\^l`.

<!-- @conclusion -->
The standard library names are `*-distribˡ-+` and `*-distribʳ-+`; you will
meet them by name in World 10.
