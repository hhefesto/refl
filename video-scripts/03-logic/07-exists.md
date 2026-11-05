# Logic 7: There exists

About 45 s. Agda.

Statement: `witness : ∃ (λ n → n + 1 ≡ 3)`

**Open.** To prove something exists in Agda, you have to actually hand it over.

1. **Do:** Read the statement.
   **Say:** There exists an `n` where `n + 1` is 3. The proof is a pair: the number, and evidence about it.

2. **Do:** Give `2 , refl`.
   **Say:** The number is 2, and `2 + 1 ≡ 3` computes, so `refl`.

**Close.** The pair contains the number. That's what "constructive proofs as data" means: the proof carries its witness around.

**Finished proof:**

```agda
witness = 2 , refl
```
