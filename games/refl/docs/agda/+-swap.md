`+-swap`

A large rearrangement can be decomposed into small, already proved equalities.

```agda
+-swap : ∀ (x y z : ℕ) → x + (y + z) ≡ y + (x + z)
```

Use the lemma by supplying arguments in the order of its type. See the lesson's worked example for the proof technique.
