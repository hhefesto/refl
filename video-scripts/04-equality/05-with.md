# Equality 5: with abstraction

About 1 min 15 s. Agda.

Statement: `δ-diag : ∀ (i : ℕ) → δ i i ≡ 1`

**Open.** One of the most common idioms in dependently typed code: `with`.

1. **Do:** Point at `δ`.
   **Say:** The Kronecker delta: 1 if `i` and `j` are equal, 0 if not. `with` matches on an expression, not just a variable.

2. **Do:** Try `refl`, press Check, show the failure.
   **Say:** Goal says `(δ i i | i ≟ i) ≡ 1`: `δ i i` is stuck, because it can't compute until `i ≟ i` does. So our proof has to ask the same question.

3. **Do:** Write `δ-diag i with i ≟ i` and `... | d = ?`, press Check, case split on `d`, give `refl` for `yes x`.
   **Say:** Same `with` as the definition, and now `δ` computes.

4. **Do:** Give `⊥-elim (x refl)` for `no x`.
   **Say:** And `no` is impossible: it claims `i` doesn't equal `i`.

**Close.** A lemma about a `with` function repeats the same `with`. Remember that one. `rewrite` is secretly a `with` on an equation.

**Finished proof:**

```agda
δ-diag i with i ≟ i
... | yes _ = refl
... | no ¬p = ⊥-elim (¬p refl)
```
