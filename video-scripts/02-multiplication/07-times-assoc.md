# Multiplication 7: *-assoc

About 1 min 00 s. Agda.

Statement: `*-assoc : ∀ (x y z : ℕ) → (x * y) * z ≡ x * (y * z)`

**Open.** The last of the ring laws, and the reason we proved distributivity first.

1. **Do:** Case split on `z`, give `refl` for `zero`.
   **Say:** Base case computes.

2. **Do:** Press Goal in the `suc` clause.
   **Say:** The left is `(x * y) * z + x * y`. The right is `x * (y * z + y)`, and that's a distributivity shape.

3. **Do:** Give `trans (cong (_+ x * y) (*-assoc x y z)) (sym (*-distribˡ-+ x (y * z) y))`.
   **Say:** Induction hypothesis in the left of the sum, then distributivity backwards. Plus binds looser than times, so `(_+ x * y)` adds the whole product.

**Close.** We've now shown that natural numbers form a commutative semiring, which is the structure real libraries take as a parameter.

**Finished proof:**

```agda
*-assoc x y zero = refl
*-assoc x y (suc z) = trans (cong (_+ x * y) (*-assoc x y z)) (sym (*-distribˡ-+ x (y * z) y))
```
