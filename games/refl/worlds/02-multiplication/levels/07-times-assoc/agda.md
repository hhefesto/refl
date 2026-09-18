---
example_explanation: |-
  1. The left side is an expanded product.
  2. The available distributivity lemma points from product to sum.
  3. Reverse it with `sym`. In the exercise use this direction after lifting the induction hypothesis through the new summand.
hints:
- hidden: false
  text: Associativity of multiplication uses distributivity to align the recursive
    step.
- hidden: true
  text: Split `z`. Lift the recursive equation under addition, then fold the resulting
    sum of products.
- hidden: true
  text: Use `trans (cong (_+ x * y) …) (sym …)`.
learning_goals:
- Associativity of `*` needs distributivity in the step.
title: '*-assoc'
---
Associativity of multiplication uses distributivity to align the recursive step.

The last of the ring laws for `ℕ`. Notice how the section `(_+ x * y)`
parses: `_+_` binds looser than `_*_`, so it is `λ w → w + (x * y)`.


<!-- @conclusion -->

With `+-comm`, `+-assoc`, `*-comm`, `*-assoc`, `*-distribˡ-+`, `zero-+`,
`one-*` you have shown `ℕ` is a commutative semiring — which is what the
standard library's `+-*-isCommutativeSemiring` packages, and what
`Weighted.lagda` takes as a parameter.
