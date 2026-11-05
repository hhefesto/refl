# Equality 10: Reading: δ is symmetric (Matrix.lagda)

About 1 min 00 s. Agda.

Statement: `δ-sym : ∀ (i j : ℕ) → δ i j ≡ δ j i`

**Open.** Last level of Equality World, and it's from `Matrix.lagda`: the Kronecker delta is symmetric.

1. **Do:** Write `δ-sym i j with i ≟ j | j ≟ i`.
   **Say:** Two questions at once, so a grid of four cases.

2. **Do:** Give `refl` for `yes _ | yes _` and `no _ | no _`.
   **Say:** When the answers agree, both sides compute the same.

3. **Do:** Give `⊥-elim (¬q (sym p))` for `yes p | no ¬q`.
   **Say:** Mixed answers are impossible: if `i ≡ j` then `j ≡ i`.

4. **Do:** Give `⊥-elim (¬p (sym q))` for `no ¬p | yes q`.
   **Say:** Same thing, the other way.

**Close.** That's Equality World. You can now read every `with`, `rewrite`, `inspect` and `subst₂` in the target code. Order World is next.

**Finished proof:**

```agda
δ-sym i j with i ≟ j | j ≟ i
... | yes _ | yes _ = refl
... | yes p | no ¬q = ⊥-elim (¬q (sym p))
... | no ¬p | yes q = ⊥-elim (¬p (sym q))
... | no _  | no _  = refl
```
