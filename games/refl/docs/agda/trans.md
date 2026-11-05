```agda
trans : ∀ {A : Set} {x y z : A} → x ≡ y → y ≡ z → x ≡ z
```

Chain two equations. `≡-Reasoning` is `trans` with the middle terms written out.
