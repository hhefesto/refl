---
id: distrib
index: 6
title: "*-distribˡ-+"
learning_goals:
  - "Distributivity by induction, with `+-assoc` in the step."
unlocks:
  lemmas:
    - name: "*-distribˡ-+"
      agda: "*-distribˡ-+"
      lean: "mul_add"
      doc: "distrib.md"
hints:
  - text: "Induction on `z`. Step: left is `x * (y + z) + x`, right is `x * y + (x * z + x)`."
  - text: "Rewrite the left with the hypothesis under `cong (_+ x)`, then `+-assoc (x * y) (x * z) x`."
    hidden: true
---
`x * (y + z) ≡ x * y + x * z`. The superscript `ˡ` says the factor is on
the left; type it as `\^l`.

<!-- @conclusion -->
The standard library names are `*-distribˡ-+` and `*-distribʳ-+`; you will
meet them by name in World 10.
