```agda
suc-+ : ∀ (x y : ℕ) → suc x + y ≡ suc (x + y)
```
The mirror of the defining clause `x + suc y = suc (x + y)`, by induction on `y`.
