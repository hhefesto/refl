---
id: induction
index: 7
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
      bend2: "zero_add"
      doc: "zero-add.md"
hints:
  - text: "**Normalise** `zero + x`: it stays stuck, because `_+_` only computes once it can see its second argument. Only `x` can be taken apart, so select the hole, put `x` in the box and press **Case split**."
  - text: "You get `zero-+ zero = ?` and `zero-+ (suc x) = ?`. The first goal is `0 ≡ 0`. The second is `suc (0 + x) ≡ suc x`, and `zero-+ x : 0 + x ≡ x` is available, because a function may call itself on a smaller argument. That call is the induction hypothesis."
  - text: "`zero-+ zero = refl`, and `zero-+ (suc x) = cong suc (zero-+ x)`."
---
`x + zero ≡ x` holds by computation: it is the first clause of `_+_`. But
`zero + x ≡ x` doesn't. The recursion is on the right argument and `x` is a
variable, so nothing can compute. `refl` will not work, and no single lemma you
have says it.

The way forward is to take `x` apart. Every natural number is either `zero` or
`suc` of a smaller one, so it is enough to handle those two cases.

**Case split** (`C-c C-c`) does this for you: select the hole, type the variable
name `x` in the box and press the button. Agda rewrites the clause into one clause
per constructor of `ℕ`. (Agda prints the number `zero` as `0` in goals. They are
the same thing.)

Then comes the idea this whole game runs on. In the `suc x` clause you may use
`zero-+ x`: the function you are defining, applied to the smaller number. That
sounds circular, but Agda's termination checker verifies that the argument really
is smaller on every call, so the recursion has to end. That is exactly what makes
it an induction principle.

<!-- @conclusion -->
Induction is recursion. Many provers have a separate `induction` command for this;
in Agda you just pattern match and call yourself, and the termination checker is
the judge.

`zero-+` is now in your inventory.
