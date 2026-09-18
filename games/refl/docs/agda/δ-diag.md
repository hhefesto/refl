`δ-diag`

Matching on a computed decision lets a stuck definition reduce.

```agda
δ : ℕ → ℕ → ℕ
δ i j with i ≟ j
... | yes _ = 1
... | no  _ = 0

δ-diag : ∀ (i : ℕ) → δ i i ≡ 1
```

Use the lemma by supplying arguments in the order of its type. See the lesson's worked example for the proof technique.
