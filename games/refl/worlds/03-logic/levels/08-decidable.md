---
id: decidable
index: 8
title: "Decidable equality"
learning_goals:
  - "`Dec A` is `yes a` or `no ¬a`: a decision *with evidence*."
  - "Writing a decision procedure is writing a proof for every case."
  - "`λ ()` refutes an impossible equation."
unlocks:
  lemmas:
    - name: "_≟_"
      agda: "_≟_"
      lean: "decEq"
      doc: "deceq.md"
hints:
  - text: "Case split on both arguments: four clauses. `zero ≟ zero` is `yes refl`. `zero ≟ suc n` is impossible to equate: `no (λ ())` — a lambda whose only pattern is absurd, because `zero ≡ suc n` has no proof."
  - text: "For `suc m ≟ suc n`, decide `m ≟ n` first: the helper `map-suc` provided in the statement lifts that decision."
  - text: "`suc m ≟ suc n = map-suc (m ≟ n)`."
    hidden: true
---
A decision procedure for equality on `ℕ`. The statement provides a helper
that lifts a decision about `m`, `n` to one about `suc m`, `suc n`:

```agda
map-suc : ∀ {m n} → Dec (m ≡ n) → Dec (suc m ≡ suc n)
map-suc (yes p) = yes (cong suc p)
map-suc (no ¬p) = no (λ { refl → ¬p refl })
```

(That `λ { refl → … }` is a pattern-matching lambda: matching the proof
of `suc m ≡ suc n` against `refl` forces `m` and `n` together.)

Write the four clauses of `_≟_`.

<!-- @conclusion -->
`_≟_` is the key to Spectra2's Kronecker delta and to every `with i ≟ j`
you will read. The language paper defines its own `Dec` in
`Decidability.lagda:25`, identical to this one.
