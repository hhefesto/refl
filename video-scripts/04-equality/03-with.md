# Equality 3: with abstraction

About 1 min 00 s. Agda.

Statement: `δ-diag : ∀ (i : ℕ) → δ i i ≡ 1`

**Open.** This is the most important idiom in the real code this game leads to: `with`.

1. **Do:** Point at `δ`.
   **Say:** The Kronecker delta: 1 if `i` and `j` are equal, 0 if not. `with` matches on an expression, not just a variable.

2. **Do:** Try `refl`, press Check, show the failure.
   **Say:** `δ i i` is stuck, because it can't compute until `i ≟ i` does. So our proof has to ask the same question.

3. **Do:** Write `δ-diag i with i ≟ i`, give `refl` for `yes _`.
   **Say:** Same `with` as the definition, and now `δ` computes.

4. **Do:** Give `⊥-elim (¬p refl)` for `no ¬p`.
   **Say:** And `no` is impossible: it claims `i` doesn't equal `i`.

**Close.** A lemma about a `with` function repeats the same `with`. Remember that one. `rewrite` is secretly a `with` on an equation.

**Finished proof:**

```agda
δ-diag i with i ≟ i
... | yes _ = refl
... | no ¬p = ⊥-elim (¬p refl)
```
