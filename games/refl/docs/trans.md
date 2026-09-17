```agda
trans : ∀ {A : Set} {x y z : A} → x ≡ y → y ≡ z → x ≡ z
```

Chain two equations. `≡-Reasoning` (World 1) is `trans` with the middle terms written out. Lean: `h₁.trans h₂` or `Eq.trans`.
