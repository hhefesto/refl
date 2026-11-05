# Tutorial 3: A variable in the way

About 1 min 00 s. Agda.

Statement: `same : ∀ (x : ℕ) → x ≡ x`

**Open.** Now there's a variable. Does `refl` still work when we don't know what the number is?

1. **Do:** Read the statement aloud.
   **Say:** For every natural number `x`, `x` equals `x`. In Agda a for-all is a function: the proof takes `x` and hands back an equality.

2. **Do:** Press Check, select the hole, press Goal.
   **Say:** Two parts. Above the line is the context, what I can use: `x : ℕ`. Below the line is what I owe.

3. **Do:** Give `refl`.
   **Say:** Both sides are literally the same expression, so nothing has to compute at all.

**Close.** Arguments on the left of the equals sign are how you introduce a for-all. Keep an eye on that context panel, because from here on it's where the proofs come from.

**Finished proof:**

```agda
same x = refl
```
