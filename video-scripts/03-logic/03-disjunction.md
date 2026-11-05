# Logic 3: Or is a choice

About 45 s. Agda.

Statement: `⊎-comm : ∀ {A B : Set} → A ⊎ B → B ⊎ A`

**Open.** Or is a choice. And unlike classical logic, a proof of "or" tells you which side is true.

1. **Do:** Case split on `s`, then rename the variables to `a` and `b`.
   **Say:** Two clauses, one per constructor: `inj₁` and `inj₂`.

2. **Do:** Give `inj₂ a` in the first clause.
   **Say:** What was on the left goes on the right.

3. **Do:** Give `inj₁ b` in the second clause.
   **Say:** And the other way around.

**Close.** Notice the symmetry with pairs. A pair is built by one constructor and taken apart two ways. A sum is built two ways and taken apart by cases.

**Finished proof:**

```agda
⊎-comm (inj₁ a) = inj₂ a
⊎-comm (inj₂ b) = inj₁ b
```
