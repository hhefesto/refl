---
id: disjunction
index: 3
title: "Or is a choice"
learning_goals:
  - "`A ⊎ B` has two constructors; a proof records which side."
  - "Case split on a sum to handle both."
unlocks:
  lemmas:
    - name: "⊎-comm"
      agda: "⊎-comm"
      lean: "Or.symm"
hints:
  - text: "**Case split** on `s`. You get `⊎-comm (inj₁ x) = ?` and `⊎-comm (inj₂ x) = ?`. Ask for each **Goal**: in the first `x : A`, in the second `x : B`, and the goal is `B ⊎ A` both times."
  - text: "In the first clause you hold an `A`, and the goal's `A` is on its *right*. **Refine** with `inj₂`. The second clause is the mirror image."
  - text: "`⊎-comm (inj₁ x) = inj₂ x`, and `⊎-comm (inj₂ x) = inj₁ x`."
---
To prove "A or B" you pick a side and prove that side. So `_⊎_` is a data type with two
constructors, each carrying a proof:

```agda
data _⊎_ (A B : Set) : Set where
  inj₁ : A → A ⊎ B
  inj₂ : B → A ⊎ B
```

Unlike a classical *or*, a proof here says *which* side holds. It's data, and a program
can look at it.

That is also how you use one. If you're given `s : A ⊎ B`, you don't know which side you
have, so you must be ready for both: **Case split** on `s` turns one clause into two.

Watch the names when you split: Agda calls the payload `x` in **both** clauses, even
though it has a different type in each, because those are two separate clauses with two
separate contexts. **Goal** shows you which `x` is which. Then decide which constructor
you need on the way out. The goal is `B ⊎ A`, with the sides swapped.

<!-- @conclusion -->
Notice the asymmetry with `×`. A pair is *built* by one constructor and *used* by two
projections. A sum is *built* by two constructors and *used* by one case analysis. They
are mirror images, which is why logicians call them duals.
