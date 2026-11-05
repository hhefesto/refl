# Multiplication 2: zero-*

About 30 s. Agda.

Statement: `zero-* : ∀ (x : ℕ) → zero * x ≡ zero`

**Open.** The mirror image. `x * zero` is `refl`, but `zero * x` isn't, for the same reason as addition.

1. **Do:** Case split on `x`, give `refl` for `zero`.
   **Say:** Base case computes.

2. **Do:** Give `zero-* x` in the `suc` clause.
   **Say:** `zero * suc x` computes to `zero * x + zero`, and adding zero computes away. So the recursive call is the proof.

**Close.** Compare it with `sumTo-zero`. Same proof, because a product is a repeated sum.

**Finished proof:**

```agda
zero-* zero = refl
zero-* (suc x) = zero-* x
```
