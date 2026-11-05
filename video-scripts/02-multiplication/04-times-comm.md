# Multiplication 4: *-comm

About 45 s. Agda.

Statement: `*-comm : ∀ (x y : ℕ) → x * y ≡ y * x`

**Open.** Remember the proof of `+-comm`? Pull it up, because this is the same proof.

1. **Do:** Case split on `y`.
   **Say:** Same split.

2. **Do:** Give `sym (zero-* x)` for `zero`.
   **Say:** `zero-*` where `+-comm` used `zero-+`.

3. **Do:** Give `trans (cong (_+ x) (*-comm x y)) (sym (suc-* y x))` for `suc`.
   **Say:** `suc-*` where it used `suc-+`, and `cong (_+ x)` where it used `cong suc`.

**Close.** Two commutativity proofs, one program, over different operations. World 8 turns that observation into a structure you prove once.

**Finished proof:**

```agda
*-comm x zero = sym (zero-* x)
*-comm x (suc y) = trans (cong (_+ x) (*-comm x y)) (sym (suc-* y x))
```
