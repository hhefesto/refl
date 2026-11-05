# Multiplication 9: Reading: a factor out of a sum

About 45 s. Agda.

Statement: `sum-factor : ∀ (c : ℕ) (f : ℕ → ℕ) (n : ℕ) → sumTo (λ i → c * f i) n ≡ c * sumTo f n`

**Open.** Reading level. Pulling a constant out of a sum shows up in nearly every proof that does algebra with sums. Here's that lemma, in miniature.

1. **Do:** Read the statement.
   **Say:** Sum of `c` times `f i` equals `c` times the sum of `f i`. High school algebra.

2. **Do:** Case split on `n`, give `refl` for `zero`.
   **Say:** Empty sum.

3. **Do:** Give the `suc` clause: `trans (cong (_+ c * f n) (sum-factor c f n)) (sym (*-distribˡ-+ c (sumTo f n) (f n)))`.
   **Say:** Induction hypothesis, then distributivity backwards. Same shape as `*-assoc`.

**Close.** That's two worlds of arithmetic done. Next up, Logic World changes the subject: types as propositions.

**Finished proof:**

```agda
sum-factor c f zero = refl
sum-factor c f (suc n) = trans (cong (_+ c * f n) (sum-factor c f n)) (sym (*-distribˡ-+ c (sumTo f n) (f n)))
```
