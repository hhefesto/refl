# Equality 4: Pattern-matching lambdas

About 30 s. Agda.

Statement: `sym′ : ∀ {A : Set} {x y : A} → x ≡ y → y ≡ x`

**Open.** Prove `sym` again, with two rules: no arguments on the left, and no using `sym`.

1. **Do:** Give `λ { refl → refl }`.
   **Say:** A lambda with curly braces is an anonymous function defined by cases. It matches on `refl`, and now `x` and `y` are the same, so `refl` closes it.

**Close.** `λ { pat → e }` for cases, `λ ()` for impossible ones. You'll see both all over real code.

**Finished proof:**

```agda
sym′ = λ { refl → refl }
```
