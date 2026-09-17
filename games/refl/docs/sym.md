```agda
sym : ∀ {A : Set} {x y : A} → x ≡ y → y ≡ x
```

Flip an equation. Lean: `h.symm` or `Eq.symm h`.
