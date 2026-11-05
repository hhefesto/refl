# Logic 12: Reading: languages as predicates

About 1 min 00 s. Agda.

Statement: `∩⊆∪ : ∀ (P Q : Pred) (n : ℕ) → (P ∩ Q) n → (P ∪ Q) n`

**Open.** Reading level, from the ICFP 2021 paper on language derivatives. A language is just a predicate.

1. **Do:** Point at the definitions of `_∪_` and `_∩_`.
   **Say:** Union is an "or" at each point, intersection is an "and" at each point. I've replaced strings with numbers to keep it simple.

2. **Do:** Case split on `pq`, then rename the parts to `p` and `_`.
   **Say:** Being in the intersection means I've got both proofs, and I only need the first.

3. **Do:** Give `inj₁ p`.
   **Say:** Being in the union means I need just one. Take the left.

**Close.** `P n` is the type of parses of `n`, and this lemma is a function turning a parse for both into a parse for either. That's Logic World.

**Finished proof:**

```agda
∩⊆∪ P Q n (p , _) = inj₁ p
```
