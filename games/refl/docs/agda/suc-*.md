`suc-*`

An induction step may need an algebraic rearrangement after the recursive proof.

```agda
suc-* : ∀ (x y : ℕ) → suc x * y ≡ x * y + y
```

Use the lemma by supplying arguments in the order of its type. See the lesson's worked example for the proof technique.
