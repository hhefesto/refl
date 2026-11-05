---
id: reading-delta-sym
index: 13
title: "Reading: δ is symmetric"
learning_goals:
  - "`with` on two scrutinees gives a grid of cases."
  - "Contradictory cases are closed with `⊥-elim` and `sym`."
hints:
  - text: "Write `δ-sym i j with i ≟ j | j ≟ i`, and four clauses: `... | yes p | yes q = ?`, `... | yes p | no ¬q = ?`, `... | no ¬p | yes q = ?` and `... | no ¬p | no ¬q = ?`. Check, and ask for each **Goal**."
  - text: "The goals are `1 ≡ 1`, `1 ≡ 0`, `0 ≡ 1` and `0 ≡ 0`. The first and last are `refl`. In the middle two the decisions disagree: one says `i ≡ j`, the other refutes `j ≡ i`. `sym` connects them."
  - text: "`... | yes p | no ¬q = ⊥-elim (¬q (sym p))`, and `... | no ¬p | yes q = ⊥-elim (¬p (sym q))`."
---
Matrix libraries prove a lot of small facts about the Kronecker delta, because that's what the identity matrix is made of. When
matrices are used to represent a weighted graph or a covariance, you soon need the identity to be symmetric, and that comes down to
this lemma:

```agda
δ-sym : ∀ (i j : ℕ) → δ i j ≡ δ j i
```

**Goal** says `(δ i j | i ≟ j) ≡ (δ j i | j ≟ i)`. So there are two stuck decisions now, and you need to know both. `with` can take
more than one expression, with `|` between them:

```agda
δ-sym i j with i ≟ j | j ≟ i
```

Each decision has two outcomes, so that's four clauses, a grid of cases. You have to write them out, one column per decision. Then
**Check** and read each **Goal**. Two of the four are the easy cases. In the other two, the decisions contradict each other, so the
case can't happen, and you've already proved this kind of thing with `⊥-elim`.

<!-- @conclusion -->
**Equality World complete.** You can now read every `with`, `rewrite`, `inspect` and `subst` you meet in real Agda code, and you've
proved Hedberg's theorem along the way.

This is the end of what's playable so far. The rest of the map shows what's planned, but those levels aren't written yet.
