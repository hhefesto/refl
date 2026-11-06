---
id: cancel
index: 10
title: "Equations between proofs"
learning_goals:
  - "A proof of an equation is a value, and two such values can be compared."
  - "`trans (sym e) e` is `refl`: a proof cancels against its inverse."
unlocks:
  lemmas:
    - name: "trans-symˡ"
      bend2: "Equality.trans_sym"
      agda: "trans-symˡ"
      lean: "trans_symm"
      doc: "trans-sym.md"
hints:
  - text: "The goal is an equation between proofs, but the method hasn't changed. **Case split** on `e`."
  - text: "After the split, `sym refl` and `trans refl refl` both compute. The goal becomes `refl ≡ refl`."
  - text: "`trans-symˡ refl = refl`."
---
The next three levels work up to one theorem, so let's start with the question it answers.

A proof of `x ≡ y` is a value, an ordinary value of a type. So it makes sense to ask whether two *proofs* are equal.
You can write that down: `p ≡ q`, for `p q : x ≡ y`. Are any two proofs of the same equation the same proof?

You might think that's obvious. There's only one constructor! But under `--without-K` it isn't provable in general,
because you can't match `p : x ≡ x` against `refl`. The endpoints are already tied together, and no variable is left
for Agda to replace.

So let's see what *can* be proved. This level's statement is an equation between proofs:

```agda
trans-symˡ : ∀ {A : Set} {x y : A} (e : x ≡ y) → trans (sym e) e ≡ refl
```

Going along `e` backwards, and then forwards again, gets you nowhere. The endpoints here are two separate variables, so
you can match on `e`.

Take a look at the goal, and then do what you've been doing all world.

<!-- @conclusion -->
A proof and its inverse cancel, just as in a group. That's a real fact about proofs, and the next level uses it.
