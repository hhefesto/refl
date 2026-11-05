# Multiplication 5: one-*

About 15 s. Agda.

Statement: `one-* : ∀ (x : ℕ) → 1 * x ≡ x`

**Open.** Quick one. No case split today.

1. **Do:** Give `trans (*-comm 1 x) (*-one x)`.
   **Say:** Swap the factors with `*-comm`, then we're at `x * 1`, which is `*-one`.

**Close.** If a lemma follows from others without induction, don't case split. Reach for `trans`.

**Finished proof:**

```agda
one-* x = trans (*-comm 1 x) (*-one x)
```
