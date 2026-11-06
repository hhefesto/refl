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
      bend2: "Addition.add_assoc"
      agda: "+-assoc"
      lean: "add_assoc"
      doc: "plus-assoc.md"
hints:
  - text: "On the left, the outer `+` looks at `z`. On the right, the outer `+` looks at `y + z`, and that looks at `z` too. **Case split** on `z`."
  - text: "The `zero` clause's goal is `x + y ≡ x + y`. The `suc` clause's is `suc (x + y + z) ≡ suc (x + (y + z))`: this same statement for the smaller `z`, under a `suc`."
  - text: "`+-assoc x y zero = refl`, and `+-assoc x y (suc z) = cong suc (+-assoc x y z)`."
---
Associativity: `(x + y) + z ≡ x + (y + z)`. There are three variables now, so the
first real question is which one to **Case split** on. The wrong choice leaves you
with goals that are stuck.

Here is how to decide without trying them all. Addition only looks at its second
argument, so take each side and ask what its outermost `+` is waiting for. On the
left, what is the second argument of the outer addition? On the right, it's a sum,
so what is *that* waiting for? You want the variable that lets **both** sides
compute at once.

A wrong guess costs nothing: press **Reset** and try another. Once you have the
right one, this is the easiest induction so far, since neither case needs any
lemma beyond the one you already reach for by reflex.

A note on reading goals: Agda prints `(x + y) + z` as `x + y + z`, without the
parentheses. Same term.

<!-- @conclusion -->
`_+_` was declared `infixl 6`, so `x + y + z` parses as `(x + y) + z`, which is why
Agda can leave the parentheses out. The standard library's `+-assoc` has exactly
this statement.
