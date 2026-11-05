# Tutorial 5: rewrite

About 1 min 00 s. Agda.

Statement: `use-h : ∀ (x : ℕ) → x ≡ 3 → x + 2 ≡ 5`

**Open.** Here's something different: a proof step you can't put in the hole, because it isn't an expression.

1. **Do:** Press Check and read the goal.
   **Say:** I know `x ≡ 3`, and I owe `x + 2 ≡ 5`. If only `x` were a three.

2. **Do:** Edit the clause to read `use-h x h rewrite h = ?`.
   **Say:** `rewrite` goes on the left of the equals sign. It rewrites the goal using `h`, left to right.

3. **Do:** Press Check, then Goal on the new hole.
   **Say:** Now it's about `3 + 2`, which computes to five.

4. **Do:** Give `refl`.
   **Say:** And that's `refl` again.

**Close.** When the goal mentions something you have an equation for, rewrite it. World 4 opens the box and shows what `rewrite` really is.

**Finished proof:**

```agda
use-h x h rewrite h = refl
```
