# Logic 8: Decidable equality

About 1 min 00 s. Agda.

Statement: `_≟_ : (m n : ℕ) → Dec (m ≡ n)`

**Open.** Not just a yes or no answer, but a yes with a proof, or a no with a proof. That's `Dec`.

1. **Do:** Case split on `m` and `n`.
   **Say:** Four clauses.

2. **Do:** Give `yes refl` for `zero ≟ zero`.
   **Say:** Zero equals zero, and here's why.

3. **Do:** Give `no (λ ())` for both mixed clauses.
   **Say:** Zero is never a successor. `λ ()` is the function that handles an impossible argument.

4. **Do:** Give `map-suc (m ≟ n)` for `suc m ≟ suc n`.
   **Say:** Decide the smaller question, and lift the answer with the helper in the statement.

**Close.** This is a program that compares numbers and a proof that it's right, in one definition. You'll see `with i ≟ j` everywhere from now on.

**Finished proof:**

```agda
zero ≟ zero = yes refl
zero ≟ suc n = no (λ ())
suc m ≟ zero = no (λ ())
suc m ≟ suc n = map-suc (m ≟ n)
```
