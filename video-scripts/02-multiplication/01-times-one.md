# Multiplication 1: *-one

About 45 s. Agda.

Statement: `*-one : ∀ (x : ℕ) → x * 1 ≡ x`

**Open.** Multiplication World. The proofs have the same shape as before, but now every step leans on what we've already built.

1. **Do:** Show the definition of `_*_`.
   **Say:** Recursion on the second argument, just like addition.

2. **Do:** Normalise `x * 1`.
   **Say:** One is `suc zero`, so `x * 1` is `x * zero + x`, and that shows up as `0 + x`.

3. **Do:** Give `zero-+ x`.
   **Say:** And we proved that in Tutorial World. No induction here.

**Close.** Half the work in this world is noticing that you've already done the work.

**Finished proof:**

```agda
*-one x = zero-+ x
```
