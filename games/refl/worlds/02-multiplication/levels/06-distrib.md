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
  - text: "**Case split** on `z`. The `suc` clause's **Goal** is `x * (y + z) + x ≡ x * y + (x * z + x)`."
  - text: "Use the recursive call on the left under `cong (_+ x)`. That leaves `x * y + x * z + x ≡ x * y + (x * z + x)`, which only moves parentheses."
  - text: "`*-distribˡ-+ x y zero = refl`, and `*-distribˡ-+ x y (suc z) = trans (cong (_+ x) (*-distribˡ-+ x y z)) (+-assoc (x * y) (x * z) x)`."
---
`x * (y + z) ≡ x * y + x * z`, the law that links the two operations. The superscript
`ˡ` in the name says the factor being distributed is on the left. You won't need to
type the name, but if you ever do, it is `\^l`.

Which variable should you **Case split** on? Look at the left side: the multiplication
looks at `y + z`, and that sum looks at `z`. On the right side `x * z` looks at `z`
too. That is the same reasoning you used for `+-assoc`, and it picks out one variable.

The `zero` clause then computes away. In the `suc` clause, read the **Goal** closely:
each side has gained a `+ x`, but not in the same position. On the left it sits around
the whole product, and on the right it is inside the second summand. So there are two
steps: use the recursive call under `(_+ x)`, and then deal with the parentheses.

<!-- @conclusion -->
The standard library uses these same names, `*-distribˡ-+` and `*-distribʳ-+`, so you
can look them up there.
