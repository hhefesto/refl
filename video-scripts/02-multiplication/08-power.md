# Multiplication 8: x ^ 2

About 45 s. Agda.

Statement: `^-two : ∀ (x : ℕ) → x ^ 2 ≡ x * x`

**Open.** x squared is x times x. Should be one line. It is, once you find the one spot that won't compute.

1. **Do:** Normalise `x ^ 2`.
   **Say:** It unfolds to `1 * x * x`. Everything computes except that `1 * x`, because `x` is a variable.

2. **Do:** Give `cong (_* x) (one-* x)`.
   **Say:** So fix that one spot with `one-*`, underneath `* x`.

**Close.** Normalise first, then look for what's stuck. That habit will save you a lot of time.

**Finished proof:**

```agda
^-two x = cong (_* x) (one-* x)
```
