```agda
zero-+ : ∀ (x : ℕ) → zero + x ≡ x
```

Proved by induction (case split on `x`, then `cong suc (zero-+ x)`). Its mirror `x + zero ≡ x` is `refl` because `_+_` recurses on the second argument.
