`contraposition`

Negation is a function that turns evidence into a contradiction.

```agda
contraposition : ∀ {A B : Set} → (A → B) → ¬ B → ¬ A
```

Use the lemma by supplying arguments in the order of its type. See the lesson's worked example for the proof technique.
