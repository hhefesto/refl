---
id: absurd
index: 4
title: "From falsity, anything"
learning_goals:
  - "`⊥` has no constructors; case splitting on it yields the absurd clause `()`."
  - "`⊤` has exactly one proof, `tt`."
unlocks:
  syntax:
    - name: "()"
      doc: "absurd.md"
hints:
  - text: "Select the first hole, put `h` in the box and press **Case split**. Agda writes `ex-falso ()`, a clause with no `=` at all, because there is no case to handle."
  - text: "Select the second hole and press **Refine** with an empty box. `⊤` has one constructor, so Agda writes `tt`."
---
Two opposite types, each with an unusual number of constructors:

```agda
record ⊤ : Set where
  constructor tt

data ⊥ : Set where
```

`⊤` is truth: it has one proof, `tt`, and that proof says nothing. `⊥` is falsity: it has
**no** constructors at all, so there's no way to build a proof of it.

There are two lemmas in this level. `trivial : ⊤` is as easy as it looks. The interesting
one is `ex-falso : ⊥ → A`, for *any* `A`: from a proof of falsity, conclude anything.

How can a function return a value of a type it knows nothing about? It never has to.
Think about what **Case split** does: it writes one clause per constructor. So what does
it do for a type with no constructors? Try it on the hypothesis `h`. There's nothing to
fill in afterwards, since the clause it writes has no right-hand side, and Agda marks it
with the **absurd pattern** `()`.

<!-- @conclusion -->
`⊥-elim` in the library is exactly `ex-falso`. You will use it whenever a hypothesis is
impossible, as in `⊥-elim (¬p refl)`.
