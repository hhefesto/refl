# Addition 3: +-assoc

About 45 s. Agda.

Statement: `+-assoc : ∀ (x y z : ℕ) → (x + y) + z ≡ x + (y + z)`

**Open.** Associativity, and this one's a treat, because the only real decision is which variable to induct on.

1. **Do:** Case split on `z`.
   **Say:** Pick `z`. Both sides have a `+ z` on the outside of something, so each one computes a `suc` per step.

2. **Do:** Give `refl` in the `zero` clause.
   **Say:** Base case computes.

3. **Do:** Give `cong suc (+-assoc x y z)` in the `suc` clause.
   **Say:** And the step is `cong suc` of the recursive call.

**Close.** Choose the right variable and the proof writes itself. Choose wrong and you'd need a pile of lemmas.

**Finished proof:**

```agda
+-assoc x y zero = refl
+-assoc x y (suc z) = cong suc (+-assoc x y z)
```
