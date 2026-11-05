# Logic 9: A decision with evidence

About 1 min 00 s. Agda.

Statement: `is-zero : (n : ℕ) → Dec (n ≡ zero)`

**Open.** A function that returns a boolean can tell you an answer, but it can't tell you why. Here's something better.

1. **Do:** Point at the definition of `Dec` in the lesson.
   **Say:** `yes` needs a proof, and `no` needs a refutation. So a decision can't be wrong: the type won't let it.

2. **Do:** Case split on `n`, then Refine with `yes` in the `zero` clause.
   **Say:** Refine opens a hole for the evidence. Zero equals zero, and I'll give `refl`.

3. **Do:** Refine with `no` in the `suc` clause, then give `λ ()`.
   **Say:** A successor is never zero, and we just saw how to say that.

**Close.** Writing a decision means proving something in every case. Next level, we decide whether any two numbers are equal.

**Finished proof:**

```agda
is-zero zero = yes refl
is-zero (suc n) = no (λ ())
```
