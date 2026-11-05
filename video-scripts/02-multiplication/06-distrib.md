# Multiplication 6: *-distribˡ-+

About 45 s. Agda.

Statement: `*-distribˡ-+ : ∀ (x y z : ℕ) → x * (y + z) ≡ x * y + x * z`

**Open.** Distributivity. Also, how to type that little superscript: backslash, caret, l.

1. **Do:** Case split on `z`, give `refl` for `zero`.
   **Say:** Base case computes.

2. **Do:** Press Goal in the `suc` clause.
   **Say:** The left computes to `x * (y + z) + x`. The right is `x * y + (x * z + x)`.

3. **Do:** Give `trans (cong (_+ x) (*-distribˡ-+ x y z)) (+-assoc (x * y) (x * z) x)`.
   **Say:** Induction hypothesis under `+ x`, then regroup with `+-assoc`.

**Close.** The standard library uses this exact name, so you'll recognize it when you see it later.

**Finished proof:**

```agda
*-distribˡ-+ x y zero = refl
*-distribˡ-+ x y (suc z) = trans (cong (_+ x) (*-distribˡ-+ x y z)) (+-assoc (x * y) (x * z) x)
```
