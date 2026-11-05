# Equality 6: with … in eq

About 45 s. Agda.

Statement: `f-nonzero : ∀ (n : ℕ) → n ≢ 0 → f n ≡ n`

**Open.** Sometimes matching on a test's result isn't enough. You also need to remember that the test gave that result.

1. **Do:** Write `f-nonzero n h with n ≡ᵇ 0 in eq`.
   **Say:** `in eq` keeps an equation saying what the test returned.

2. **Do:** Give `refl` for `false`.
   **Say:** `f n` computes to `n`.

3. **Do:** Give `⊥-elim (h (≡ᵇ⇒≡ n 0 eq))` for `true`.
   **Say:** Here `eq` says the test came back true, `≡ᵇ⇒≡` turns that into `n ≡ 0`, and `h` says that can't be.

**Close.** Boolean tests have to be remembered to be reasoned about, and real code uses this exact form.

**Finished proof:**

```agda
f-nonzero n h with n ≡ᵇ 0 in eq
... | true  = ⊥-elim (h (≡ᵇ⇒≡ n 0 eq))
... | false = refl
```
