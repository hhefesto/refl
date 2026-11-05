---
id: exists
index: 7
title: "There exists"
learning_goals:
  - "`∃ P` (a `Σ` type) is a witness paired with a proof about it."
  - "The witness is data: you choose it."
unlocks:
  syntax:
    - name: "Σ / ∃"
      doc: "sigma.md"
hints:
  - text: "Select the hole and press **Refine** with an empty box to get `? , ?`. The first hole wants a number. Which `n` makes `n + 1 ≡ 3`?"
  - text: "With the first hole filled, **Check**, and the second hole's **Goal** is `3 ≡ 3`."
  - text: "`witness = 2 , refl`."
---
How do you prove that something exists? In ordinary maths you might argue that it can't
fail to. Here, you show it. A proof of "there is an `n` such that `P n`" is a **pair**: a
particular number, called the **witness**, and a proof that it works.

```agda
record Σ (A : Set) (B : A → Set) : Set where
  constructor _,_
  field
    fst : A
    snd : B fst

∃ : ∀ {A : Set} → (A → Set) → Set
```

Look at the type of `snd`, `B fst`. The type of the second component mentions the *value*
of the first. `∃ (λ n → n + 1 ≡ 3)` is the type of pairs `n , p` where `p` proves
`n + 1 ≡ 3` for that very `n`.

So there are two holes to fill, and they aren't independent. You pick the witness first,
since it's data and the choice is yours. Then the type of the second hole depends on what
you picked.

<!-- @conclusion -->
Unlike classical existence, the pair *contains* the number. You can take a proof of
existence and compute with what's inside it.

A `Σ` type generalises `×`: `A × B` is `Σ A (λ _ → B)`, the case where the second
component's type doesn't mention the first.
