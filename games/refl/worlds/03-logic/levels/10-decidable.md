---
id: decidable
index: 10
title: "Decidable equality"
learning_goals:
  - "`suc m ≟ suc n` reduces to `m ≟ n`, so a decision can recurse."
  - "A pattern-matching lambda `λ { refl → … }` takes apart an equation."
  - "Reading a helper from the statement and using it."
unlocks:
  lemmas:
    - name: "_≟_"
      agda: "_≟_"
      lean: "decEq"
      doc: "deceq.md"
hints:
  - text: "Put `m n` in the box and press **Case split**. You get four clauses, one for each combination of `zero` and `suc`. Three of them you already know how to do."
  - text: "`zero ≟ zero` is `yes refl`, and the two mixed clauses are `no (λ ())`. In the last clause the goal is `Dec (suc m ≡ suc n)`. The recursive call `m ≟ n` decides the smaller question, and `map-suc` lifts its answer."
  - text: "`suc m ≟ suc n = map-suc (m ≟ n)`."
---
Are two numbers equal? Here's a decision procedure for that, and it's the one you'll use
for the rest of the game. `m ≟ n` has type `Dec (m ≡ n)`. Type `≟` as `\?=`.

You need all four combinations of `zero` and `suc`. Three of them are like the last level.
The new one is when both numbers are successors, because then the answer depends on the
smaller numbers: `suc m` equals `suc n` exactly when `m` equals `n`. So decide `m ≟ n` first,
with a recursive call, and turn its answer into an answer to the bigger question.

Turning one into the other takes a little work, so the statement gives you a helper:

```agda
map-suc : ∀ {m n} → Dec (m ≡ n) → Dec (suc m ≡ suc n)
map-suc (yes p) = yes (cong suc p)
map-suc (no ¬p) = no (λ { refl → ¬p refl })
```

Read it, because each line is a small proof. If `p` proves `m ≡ n`, then `cong suc p`
proves `suc m ≡ suc n`. And if `¬p` refutes `m ≡ n`, you must refute `suc m ≡ suc n`. That
takes a pattern-matching lambda: `λ { refl → … }` matches the proof against `refl`, which
forces `m` and `n` to be the same, and then `¬p refl` is `⊥`.

<!-- @conclusion -->
`_≟_` is now in your inventory, and you'll see `with i ≟ j` a lot in Equality World. Any
function that compares numbers and then has to *prove* something about the result starts
from a decision like this one.
