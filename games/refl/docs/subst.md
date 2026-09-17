```agda
subst : ∀ {A : Set} (P : A → Set) {x y : A} → x ≡ y → P x → P y
```
Transport along an equation; the motive `P` is usually a section like `(x ≡_)`. `subst₂` takes two equations. Lean: `h ▸ p` / `Eq.subst`.
