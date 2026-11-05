---
id: negation
index: 5
title: "Negation is a function to ⊥"
learning_goals:
  - "`¬ A` unfolds to `A → ⊥`, so a proof of `¬ A` takes an `A`."
  - "Contraposition without classical logic."
unlocks:
  lemmas:
    - name: "contraposition"
      agda: "contraposition"
      lean: "mt"
hints:
  - text: "Select the hole and press **Goal**: it says `(B → ⊥) → A → ⊥`. **Refine** with an empty box introduces both arguments as `λ x x₁ → ?`, or you can name them yourself: `contraposition f ¬b a = ?`."
  - text: "The goal is now `⊥`. The only thing that can produce a `⊥` is the refutation of `B`, and it needs a `B`. Where can you get one?"
  - text: "`contraposition f ¬b a = ¬b (f a)`."
---
Negation isn't a new connective. It's defined in terms of the ones you have:

```agda
¬_ : Set → Set
¬ A = A → ⊥
```

"Not A" means: from a proof of `A`, I could produce a proof of falsity. So a proof of
`¬ A` is a function, and *using* a negation means applying it.

This statement is **contraposition**: if `A` implies `B`, then not-`B` implies not-`A`.
It looks like it must be a difficult argument, but ask for the **Goal** in the hole and
you'll see what it really is once `¬` has been unfolded: a function type with two more
arguments, ending in `⊥`.

So introduce those arguments, the way you did in this world's first level. You'll then
have two functions and a value in your context, and a goal of `⊥`. Follow the types:
start from what you need and work backwards.

<!-- @conclusion -->
Constructively, `¬ ¬ A → A` is *not* provable in general, but `A → ¬ ¬ A` and
contraposition are. Agda's logic is constructive: a proof is a program, so it can't
conjure an `A` out of the absence of a refutation.
