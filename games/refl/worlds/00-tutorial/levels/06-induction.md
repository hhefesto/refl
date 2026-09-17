---
id: induction
index: 6
title: "Case split is induction"
learning_goals:
  - "**Case split** (`C-c C-c`) on a variable replaces one clause by one per constructor."
  - "A recursive call on the smaller argument *is* the induction hypothesis."
  - "`zero + x ≡ x` does not hold by definition; `x + zero ≡ x` does."
unlocks:
  commands: [case]
  lemmas:
    - name: "zero-+"
      agda: "zero-+"
      lean: "zero_add"
      doc: "zero-add.md"
hints:
  - text: "Normalise `zero + x`: it is stuck, because `_+_` only computes when its **second** argument is `zero` or `suc`. So look at `x`: put `x` in the box, select the hole and press **Case split**."
  - text: "You get two clauses: `zero-+ zero = ?` and `zero-+ (suc x) = ?`. The first is `refl`. In the second the goal is `suc (zero + x) ≡ suc x` — and `zero-+ x : zero + x ≡ x` is available, because a function may call itself on a smaller argument. That is the induction hypothesis."
  - text: "Second clause: `cong suc (zero-+ x)`."
    hidden: true
---
`x + zero ≡ x` is `refl` (first clause of `_+_`). `zero + x ≡ x` is not: the
recursion is on the right argument and `x` is a variable, so nothing computes.

The move is **Case split**: select the hole, type the variable name `x` in the
box, press Case split. Agda rewrites the clause into one clause per
constructor of `ℕ`. Then, in the `suc x` clause, you may use `zero-+ x` — the
function you are defining, applied to the smaller number. Agda's termination
checker verifies that this is well-founded, which is exactly what makes it an
induction principle rather than a circular argument.

<!-- @conclusion -->
Induction is recursion. NNG4 spells it `induction n with d hd`; in Agda you
just pattern match and call yourself. The termination checker is the judge.

`zero-+` is now in your inventory.
