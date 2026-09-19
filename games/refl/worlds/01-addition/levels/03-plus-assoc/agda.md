---
title: "+-assoc"
learning_goals:
  - "A proof by induction where every case is `refl` or `cong suc`."
  - "Reading parentheses: `x + y + z` means `(x + y) + z` because `_+_` is `infixl 6`."
hints:
  - text: "Induction on `z`: it is the outermost right argument on both sides."
  - text: "`+-assoc x y zero = refl`; `+-assoc x y (suc z) = cong suc (+-assoc x y z)`."
    hidden: true
example_explanation: |-
  1. Three variables, but `_+_` only computes on its second argument, and `z` is the innermost second argument on both sides: split `z`.
  2. `z = zero`: `y + zero` and `(x + y) + zero` both compute away; `refl`.
  3. `z = suc z`: both sides become `suc (…)`, so `cong suc` of the recursive call.
  The exercise is the mirror image: same split, same two clauses.
---
Associativity. Choose the induction variable so that both sides compute one
`suc` per step.

<!-- @conclusion -->
`_+_` was declared `infixl 6`, so `x + y + z` parses as `(x + y) + z`. The
standard library's `+-assoc` has exactly this statement.
