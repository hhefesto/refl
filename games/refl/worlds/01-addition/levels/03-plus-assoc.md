---
id: plus-assoc
index: 3
title: "+-assoc"
learning_goals:
  - "A proof by induction where every case is `refl` or `cong suc`."
  - "Reading parentheses: `x + y + z` means `(x + y) + z` because `_+_` is `infixl 6`."
unlocks:
  lemmas:
    - name: "+-assoc"
      agda: "+-assoc"
      lean: "add_assoc"
      doc: "plus-assoc.md"
hints:
  - text: "Induction on `z`: it is the outermost right argument on both sides."
  - text: "`+-assoc x y zero = refl`; `+-assoc x y (suc z) = cong suc (+-assoc x y z)`."
    hidden: true
---
Associativity. Choose the induction variable so that both sides compute one
`suc` per step.

<!-- @conclusion -->
`_+_` was declared `infixl 6`, so `x + y + z` parses as `(x + y) + z`. The
standard library's `+-assoc` has exactly this statement.
