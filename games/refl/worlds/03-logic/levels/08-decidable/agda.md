---
example_explanation: |-
  1. Split the number into its constructors.
  2. Zero equals zero, with evidence `refl`.
  3. A successor cannot equal zero, so its refutation is `λ ()`. The exercise also compares two successors, where a recursive decision is needed.
hints:
- hidden: false
  text: A decision procedure returns a proof or a refutation, rather than a bare Boolean.
- hidden: true
  text: Split both numbers. Different constructors cannot be equal; two successors
    reduce to the smaller comparison.
- hidden: true
  text: In the successor/successor clause use `map-suc (…)` on the recursive decision.
learning_goals:
- '`Dec A` is `yes a` or `no ¬a`: a decision *with evidence*.'
- Writing a decision procedure is writing a proof for every case.
- '`λ ()` refutes an impossible equation.'
title: Decidable equality
---
A decision procedure returns a proof or a refutation, rather than a bare Boolean.

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
