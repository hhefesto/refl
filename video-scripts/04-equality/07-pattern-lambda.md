# Equality 7: Pattern-matching lambdas

About 30 s. Agda.

Statement: `sym′ : ∀ {A : Set} {x y : A} → x ≡ y → y ≡ x`

**Open.** Prove `sym` again, with two rules: no arguments on the left, and no using `sym`.

1. **Do:** Give `λ { refl → refl }`.
   **Say:** A lambda with curly braces is an anonymous function defined by cases. It matches on `refl`, and now `x` and `y` are the same, so `refl` closes it.

**Close.** `λ { pat → e }` for cases, `λ ()` for impossible ones. Isomorphisms in the language paper are built out of exactly this.

**Finished proof:**

```agda
sym′ = λ { refl → refl }
```
