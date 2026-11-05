# Addition 8: Reading: a finite sum

About 1 min 00 s. Agda.

Statement: `sumTo-zero : ∀ (n : ℕ) → sumTo (λ _ → zero) n ≡ zero`

**Open.** Reading level. Real proof libraries spend a lot of effort on facts about finite sums, and they all look like this.

1. **Do:** Point at `sumTo`.
   **Say:** `sumTo f n` adds up `f 0` through `f (n - 1)`. It takes a function as an argument, and it's defined by recursion.

2. **Do:** Case split on `n`, give `refl` for `zero`.
   **Say:** An empty sum is zero.

3. **Do:** Give `sumTo-zero n` in the `suc` clause.
   **Say:** Adding one more zero computes away, so the recursive call is already the whole proof.

**Close.** A sum is a fold, and a lemma about a sum is an induction on its length. That's Addition World done.

**Finished proof:**

```agda
sumTo-zero zero = refl
sumTo-zero (suc n) = sumTo-zero n
```
