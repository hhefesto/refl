```agda
+-cancelʳ : ∀ (x y z : ℕ) → x + z ≡ y + z → x ≡ y
```
Induction on `z`, shrinking the hypothesis with `suc-injective`.
