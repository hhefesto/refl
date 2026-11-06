---
id: times-assoc
index: 7
title: "*-assoc"
learning_goals:
  - "Associativity of `*` needs distributivity in the step."
unlocks:
  lemmas:
    - name: "*-assoc"
      bend2: "Multiplication.mul_assoc"
      agda: "*-assoc"
      lean: "mul_assoc"
hints:
  - text: "**Case split** on `z`. The `suc` clause's **Goal** is `x * y * z + x * y ≡ x * (y * z + y)`. On the right, a product with a sum inside: which lemma opens that up?"
  - text: "Use the recursive call on the left under `cong (_+ x * y)`, then `*-distribˡ-+` backwards to reach the right side."
  - text: "`*-assoc x y zero = refl`, and `*-assoc x y (suc z) = trans (cong (_+ x * y) (*-assoc x y z)) (sym (*-distribˡ-+ x (y * z) y))`."
---
`(x * y) * z ≡ x * (y * z)`, the last of the semiring laws for `ℕ`. As with `+-assoc`,
`z` is the variable that lets both sides compute.

The difference from `+-assoc` shows up in the inductive step. There, both sides gained
a `suc` and you could go straight under it. Here, read the **Goal**: the left side is a
sum, but the right side is a product *of* a sum. You can't use the recursive call until
those two have the same shape, and the lemma you proved in the last level does that.

You will need a section around the recursive call, and this one is worth reading
slowly: `(_+ x * y)`. How does it parse? `_+_` binds looser than `_*_`, so it means
`λ w → w + (x * y)`. It adds the *product* `x * y`.

<!-- @conclusion -->
With `+-comm`, `+-assoc`, `*-comm`, `*-assoc`, `*-distribˡ-+`, `zero-+`, `zero-*` and
`one-*` you have shown that `ℕ` is a **commutative semiring**. The standard library
packages exactly this as `+-*-isCommutativeSemiring`.
