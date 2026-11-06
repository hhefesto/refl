---
id: iff
index: 11
title: "If and only if"
learning_goals:
  - "`A ⇔ B` is a record of two functions, `to` and `from`."
  - "Reusing earlier lemmas as record fields."
unlocks:
  lemmas:
    - name: "×-swap-⇔"
      bend2: "Logic.and_swap_iff"
      agda: "×-swap-⇔"
      lean: "And.comm"
hints:
  - text: "Select the hole and press **Refine** with an empty box. Agda writes `mk⇔ ? ?`, and the two new goals are `A × B → B × A` and `B × A → A × B`."
  - text: "You proved exactly that, for any `A` and `B`, earlier in this world. It's in your inventory, and it fits both holes."
  - text: "`×-swap-⇔ = mk⇔ ×-comm ×-comm`."
---
"A if and only if B" means two things: `A` implies `B`, and `B` implies `A`. So a proof of it
is two functions, one for each direction, packaged in a record:

```agda
record _⇔_ (A B : Set) : Set where
  constructor mk⇔
  field
    to   : A → B
    from : B → A
```

You've built a record before: `a , b` was the constructor of `_×_`. Here the constructor
is called `mk⇔`, and it takes the two functions as arguments.

The statement is `(A × B) ⇔ (B × A)`: "A and B" holds exactly when "B and A" does.

You could write out both functions from scratch. But look through your inventory first,
since you may have proved one already. Proofs are values, so you can pass a lemma you've
proved as an argument, just like any other function.

<!-- @conclusion -->
The standard library's `Function.Bundles` has the same `mk⇔`, `to` and `from`. It also has
`Inverse` and `mk↔`, for when the two directions undo each other.
