# Addition 6: suc is injective

About 45 s. Agda.

Statement: `suc-injective : ∀ {x y : ℕ} → suc x ≡ suc y → x ≡ y`

**Open.** If `suc x` equals `suc y`, then `x` equals `y`. There's a sneaky one-liner for this.

1. **Do:** Point at `pred` in the statement.
   **Say:** The predecessor function undoes `suc`.

2. **Do:** Give `cong pred h`.
   **Say:** Apply `pred` to both sides of `h`. `pred (suc x)` computes to `x`, so that's the goal.

3. **Do:** Mention the other way: `suc-injective refl = refl`.
   **Say:** You could also match on the proof itself. Writing `refl` on the left tells Agda the two sides unify.

**Close.** That second trick is your first taste of dependent pattern matching, which is what Equality World is all about.

**Finished proof:**

```agda
suc-injective h = cong pred h
```
