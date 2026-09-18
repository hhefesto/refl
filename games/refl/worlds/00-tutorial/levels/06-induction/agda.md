---
example_explanation: |-
  1. Split the recursive input into `zero` and `suc n`.
  2. The base equation computes.
  3. In the step, `example n` proves the smaller equation; `cong suc` lifts it. Transfer the choice of recursion variable and the lifted induction hypothesis to the exercise.
hints:
- hidden: false
  text: A proof for every natural number follows its zero/successor structure.
- hidden: true
  text: Addition is stuck on the variable `x`. Split that variable and use the recursive
    call only on the smaller predecessor.
- hidden: true
  text: Write `zero-+ zero = …` and `zero-+ (suc x) = cong suc …`.
learning_goals:
- '**Case split** (`C-c C-c`) on a variable replaces one clause by one per constructor.'
- A recursive call on the smaller argument *is* the induction hypothesis.
- '`zero + x ≡ x` does not hold by definition; `x + zero ≡ x` does.'
title: Case split is induction
---
A proof for every natural number follows its zero/successor structure.

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
