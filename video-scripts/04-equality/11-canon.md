# Equality 11: A canonical proof

About 1 min 15 s. Agda.

Statement: `canon-inv : ∀ {x y : ℕ} (p : x ≡ y) → trans (sym (canon refl)) (canon p) ≡ p`

**Open.** Natural numbers have decidable equality. That gives us a way to take any proof of an equation, ignore it, and get the same canonical proof back every time.

1. **Do:** Point at `canon` in the statement.
   **Say:** `canon p` asks `x ≟ y` and returns the proof that comes back. It only uses `p` to rule out the `no` case. So `canon p` doesn't depend on which `p` you gave it: that's `canon-const`.

2. **Do:** Read `canon-inv`.
   **Say:** Compose the canonical proof with the inverse of `canon refl`, and you're back at `p`.

3. **Do:** Case split on `p`, then press Check.
   **Say:** The hole list now says `trans (sym (canon refl)) (canon refl) ≡ refl`. Does that look familiar?

4. **Do:** Give `trans-symˡ (canon refl)`.
   **Say:** That's last level's lemma.

**Close.** Every proof can be rebuilt from its canonical version, and the canonical version doesn't depend on the proof. You can probably see where this is going.

**Finished proof:**

```agda
canon-inv refl = trans-symˡ (canon refl)
```
