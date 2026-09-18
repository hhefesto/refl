`*-assoc`

Associativity of multiplication uses distributivity to align the recursive step.

```agda
*-assoc : ∀ (x y z : ℕ) → (x * y) * z ≡ x * (y * z)
```

Use the lemma by supplying arguments in the order of its type. See the lesson's worked example for the proof technique.
