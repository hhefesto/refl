# Tutorial 7: Case split is induction

About 1 min 00 s. Agda.

Statement: `zero-+ : ∀ (x : ℕ) → zero + x ≡ x`

**Open.** This looks trivial. Zero plus x is x. But `refl` can't do it, because addition recurses on the right and `x` is a variable. So nothing computes.

1. **Do:** Try `refl`, press Check, show the error.
   **Say:** There's the failure. The checker is stuck on `zero + x`.

2. **Do:** Select the hole, type `x`, press Case split.
   **Say:** One clause becomes two: one for `zero`, one for `suc x`. This is induction.

3. **Do:** Give `refl` in the `zero` clause.
   **Say:** The base case computes.

4. **Do:** In the `suc` clause, press Goal, then Give `cong suc (zero-+ x)`.
   **Say:** The goal is `suc (zero + x) ≡ suc x`. I call the function I'm defining on the smaller number. That recursive call is the induction hypothesis.

**Close.** Induction is recursion, and the termination checker is the judge. `zero-+` is now in your inventory.

**Finished proof:**

```agda
zero-+ zero = refl
zero-+ (suc x) = cong suc (zero-+ x)
```
