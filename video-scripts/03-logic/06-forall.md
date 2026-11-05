# Logic 6: For all

About 45 s. Agda.

Statement: `∀-× : ∀ {P Q : ℕ → Set} → (∀ n → P n × Q n) → (∀ n → P n) × (∀ n → Q n)`

**Open.** A for-all is a function. And the things it talks about, predicates, are functions from numbers to types.

1. **Do:** Read the statement.
   **Say:** If every `n` has both `P` and `Q`, then every `n` has `P`, and every `n` has `Q`.

2. **Do:** Give `(λ n → proj₁ (h n)) , (λ n → proj₂ (h n))`.
   **Say:** Build a pair of two functions. Each one calls `h` and takes the side it needs.

**Close.** A predicate on strings is what theory of computation calls a language, and that's where this world's last level is going.

**Finished proof:**

```agda
∀-× h = (λ n → proj₁ (h n)) , (λ n → proj₂ (h n))
```
