# Tutorial 6: Refine and Normalise

About 1 min 00 s. Agda.

Statement: `three-steps : ∀ (x : ℕ) → (x + 2) + 1 ≡ x + 3`

**Open.** Two new commands today, and one question: how do you know whether `refl` will work before you try it?

1. **Do:** Select the hole, type `(x + 2) + 1`, press Normalise.
   **Say:** Normalise computes as far as the definitions allow. This gives `suc (suc (suc x))`.

2. **Do:** Normalise `x + 3`.
   **Say:** Same answer. Both sides reach the same term, so `refl` has to work, even with a variable in there.

3. **Do:** Mention Refine, then Give `refl`.
   **Say:** Refine is Give's more forgiving sibling: it opens new holes for whatever's missing. We'll lean on it soon. Here `refl` needs no holes.

**Close.** It worked because the numerals sit on the right, where addition computes. Put them on the left and computing gets stuck. That's next, and it's where induction starts.

**Finished proof:**

```agda
three-steps x = refl
```
