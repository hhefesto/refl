# Multiplication 3: suc-*

About 1 min 00 s. Agda.

Statement: `suc-* : ∀ (x y : ℕ) → suc x * y ≡ x * y + y`

**Open.** This is the first step in the game where the induction hypothesis alone isn't enough.

1. **Do:** Case split on `y`, give `refl` for `zero`.
   **Say:** Base case computes.

2. **Do:** Press Goal in the `suc` clause.
   **Say:** Both sides compute to a `suc` of something, so the proof starts with `cong suc`.

3. **Do:** Write the `begin` block: `cong (_+ x) (suc-* x y)`.
   **Say:** Inside, use the induction hypothesis under `+ x`.

4. **Do:** Add the step `+-right-comm (x * y) y x`.
   **Say:** Now the sides hold the same sum in a different order, and we've got a lemma for that.

**Close.** When nested `cong` and `trans` get confusing, write a `begin` block. That's what it's for.

**Finished proof:**

```agda
suc-* x zero = refl
suc-* x (suc y) = cong suc
  (begin
    suc x * y + x ≡⟨ cong (_+ x) (suc-* x y) ⟩
    x * y + y + x ≡⟨ +-right-comm (x * y) y x ⟩
    x * y + x + y ∎)
```
