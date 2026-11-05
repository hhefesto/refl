# Equality 2: Function equality and ≗

About 45 s. Agda.

Statements: `cong-app : … f ≡ g → ∀ x → f x ≡ g x` and `≗-trans : … f ≗ g → g ≗ h → f ≗ h`

**Open.** When are two functions equal? It's a trickier question than it sounds.

1. **Do:** Case split on `e` in `cong-app`, give `refl`.
   **Say:** Equal functions agree everywhere. Match on `refl` and it's immediate.

2. **Do:** Point at the definition of `_≗_`.
   **Say:** Pointwise equality: they agree on every input. Agda can't go from this back to `f ≡ g`, so real developments state things with `≗`.

3. **Do:** Give `trans (p x) (q x)` for `≗-trans`.
   **Say:** It's a function, so it takes `x`, and then it's plain `trans`.

**Close.** When you see `≗` in real Agda code, this is what it means.

**Finished proof:**

```agda
cong-app refl x = refl

≗-trans p q x = trans (p x) (q x)
```
