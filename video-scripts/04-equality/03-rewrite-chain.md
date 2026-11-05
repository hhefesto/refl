# Equality 3: Rewrite chains

About 45 s. Agda.

Statement: `two-three : ∀ (x y : ℕ) → x ≡ 2 → y ≡ 3 → x + y ≡ 5`

**Open.** Quick one. You can rewrite with more than one equation at a time.

1. **Do:** Edit the clause to `two-three x y p q rewrite p | q = ?`.
   **Say:** Separate them with a bar. They apply in order, each left to right.

2. **Do:** Press Check, press Goal, give `refl`.
   **Say:** The hole list says `2 + 3 ≡ 5`, and Goal computes that to `5 ≡ 5`.

**Close.** If an equation points the wrong way, flip it with `sym`. Real proofs have exactly this line in them.

**Finished proof:**

```agda
two-three x y p q rewrite p | q = refl
```
