---
title: "mul_add"
learning_goals:
  - "Distributivity by induction, with `add_assoc` in the step."
hints:
  - text: "`match z:`. The `1n+p` case's **Goal** is `{Refl.add(Refl.mul(x, Refl.add(y, p)), x) == Refl.add(Refl.mul(x, y), Refl.add(Refl.mul(x, p), x)) : Nat}`."
  - text: "Use the recursive call on the left, under `n => Refl.add(n, x)`. That leaves `Refl.add(Refl.add(Refl.mul(x, y), Refl.mul(x, p)), x)` against the right side, which only moves parentheses."
  - text: "`Equal.trans(Nat, Refl.add(Refl.mul(x, Refl.add(y, p)), x), Refl.add(Refl.add(Refl.mul(x, y), Refl.mul(x, p)), x), Refl.add(Refl.mul(x, y), Refl.add(Refl.mul(x, p), x)), Equal.cong(Nat, Nat, n => Refl.add(n, x), Refl.mul(x, Refl.add(y, p)), Refl.add(Refl.mul(x, y), Refl.mul(x, p)), mul_add(x, y, p)), Addition.add_assoc(Refl.mul(x, y), Refl.mul(x, p), x))`."
example_explanation: |-
  1. With a known `2n`, Bend computes both sides as far as it can, and no induction is needed.
  2. Regroup with `add_assoc`.
  3. The remaining `Refl.add(0n, x)` needs `zero_add`, under `Equal.cong`. The exercise proves the general law, by induction.
---
`Refl.mul(x, Refl.add(y, z)) == Refl.add(Refl.mul(x, y), Refl.mul(x, z))`, the law that links the two operations.

Which variable should you match on? Look at the left side: the multiplication looks at `Refl.add(y, z)`, and that looks at `z`. On the right side `Refl.mul(x, z)` looks at `z` too. That's the same reasoning you used for `add_assoc`, and it picks out one variable.

The `0n` case computes away. In the `1n+p` case, read the **Goal** closely: each side has gained an `x`, but not in the same position. On the left it sits around the whole product, and on the right it's inside the second summand. So there are two steps: use the recursive call under `n => Refl.add(n, x)`, then deal with the parentheses.

<!-- @conclusion -->
You now have the law that lets you multiply out any product of sums, and the next level needs it straight away.
