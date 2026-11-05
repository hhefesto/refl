```agda
trans-symˡ : ∀ {A : Set} {x y : A} (e : x ≡ y) → trans (sym e) e ≡ refl
```
A proof and its inverse cancel. The standard library's name is `trans-symˡ`.
