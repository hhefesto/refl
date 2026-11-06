---
title: "mul_assoc"
learning_goals:
  - "Associativity of `mul` needs distributivity in the step."
hints:
  - text: "`match z:`. The `1n+p` case's **Goal** is `{Refl.add(Refl.mul(Refl.mul(x, y), p), Refl.mul(x, y)) == Refl.mul(x, Refl.add(Refl.mul(y, p), y)) : Nat}`. On the right, a product with a sum inside: which lemma opens that up?"
  - text: "Use the recursive call on the left under `n => Refl.add(n, Refl.mul(x, y))`, then `mul_add` backwards to reach the right side."
  - text: "`Equal.trans(Nat, Refl.add(Refl.mul(Refl.mul(x, y), p), Refl.mul(x, y)), Refl.add(Refl.mul(x, Refl.mul(y, p)), Refl.mul(x, y)), Refl.mul(x, Refl.add(Refl.mul(y, p), y)), Equal.cong(Nat, Nat, n => Refl.add(n, Refl.mul(x, y)), Refl.mul(Refl.mul(x, y), p), Refl.mul(x, Refl.mul(y, p)), mul_assoc(x, y, p)), Equal.sym(Nat, Refl.mul(x, Refl.add(Refl.mul(y, p), y)), Refl.add(Refl.mul(x, Refl.mul(y, p)), Refl.mul(x, y)), Multiplication.mul_add(x, Refl.mul(y, p), y)))`."
example_explanation: |-
  1. The left side is an expanded product.
  2. `mul_add` points from product to sum.
  3. Reverse it with `Equal.sym`. In the exercise use this direction after lifting the recursive call through the new summand.
---
`Refl.mul(Refl.mul(x, y), z) == Refl.mul(x, Refl.mul(y, z))`, the last of the semiring laws for `Nat`. As with `add_assoc`, `z` is the variable that lets both sides compute.

The difference from `add_assoc` shows up in the inductive step. There, both sides gained a `1n+`, and you could go straight under it. Here, read the **Goal**: the left side is a sum, but the right side is a product *of* a sum. You can't use the recursive call until those two have the same shape, and the lemma you proved in the last level does that.

You'll need a function around the recursive call that holds the product `Refl.mul(x, y)` fixed: `n => Refl.add(n, Refl.mul(x, y))`.

<!-- @conclusion -->
With `add_comm`, `add_assoc`, `mul_comm`, `mul_assoc`, `mul_add`, `zero_add`, `zero_mul` and `one_mul` you've shown that `Nat` with these operations is a **commutative semiring**.
