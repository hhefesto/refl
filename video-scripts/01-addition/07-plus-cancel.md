# Addition 7: +-cancelʳ

About 45 s. Agda.

Statement: `+-cancelʳ : ∀ (x y z : ℕ) → x + z ≡ y + z → x ≡ y`

**Open.** Cancellation. The new thing here: the hypothesis changes shape while we work.

1. **Do:** Case split on `z`, then give `h` in the `zero` clause.
   **Say:** With `z` at zero, `h` computes to exactly `x ≡ y`.

2. **Do:** Press Goal in the `suc` clause and read `h`.
   **Say:** Now `h` computes to `suc (x + z) ≡ suc (y + z)`.

3. **Do:** Give `+-cancelʳ x y z (suc-injective h)`.
   **Say:** Strip the `suc` off with last level's lemma, and pass that smaller hypothesis to the recursive call.

**Close.** That's the pattern for every cancellation lemma: the inductive call takes a smaller hypothesis, built from the current one.

**Finished proof:**

```agda
+-cancelʳ x y zero h = h
+-cancelʳ x y (suc z) h = +-cancelʳ x y z (suc-injective h)
```
