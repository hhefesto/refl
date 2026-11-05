# Equality 7: The old inspect idiom

About 45 s. Agda.

Statement: `g-nonzero : ∀ (n : ℕ) → n ≢ 0 → g n ≡ n`

**Open.** A bit of archaeology. Before `with … in`, people did this with a trick called inspect, and old code is full of it.

1. **Do:** Point at `inspect` and `[_]`.
   **Say:** It's a small record holding an equation.

2. **Do:** Write `g-nonzero n h with n ≡ᵇ 0 | inspect (n ≡ᵇ_) 0`.
   **Say:** Two columns: the test, and the inspection of the test.

3. **Do:** Give the `true` clause with `[ eq ]`: `⊥-elim (h (≡ᵇ⇒≡ n 0 eq))`.
   **Say:** Same contradiction as last level.

4. **Do:** Give `refl` for `false | _`.
   **Say:** And the same `refl`.

**Close.** When you see `inspect` in a file, read it as `with … in eq`. Same proof, older clothes.

**Finished proof:**

```agda
g-nonzero n h with n ≡ᵇ 0 | inspect (n ≡ᵇ_) 0
... | true  | [ eq ] = ⊥-elim (h (≡ᵇ⇒≡ n 0 eq))
... | false | _ = refl
```
