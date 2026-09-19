---
title: "Hedberg: decidable equality gives UIP"
learning_goals:
  - "Under `--without-K`, `p ≡ q` for two proofs of `x ≡ y` is not automatic."
  - "With decidable equality it is provable: canonicalise every proof through the decision."
  - "Reading a scaffolded proof and filling the gaps."
hints:
  - text: "`trans-symˡ`: match the equation against `refl`; then both sides compute to `refl`."
  - text: "`canon-inv refl`: the goal is `trans (sym (canon refl)) (canon refl) ≡ refl` — exactly `trans-symˡ (canon refl)`."
  - text: "The middle step of `≡-irrelevant` rewrites `canon p` to `canon q` under `trans (sym (canon refl))`: `cong (trans (sym (canon refl))) (canon-const p q)`."
    hidden: true
example_explanation: |-
  1. Generalize both endpoints of the equality proof.
  2. Match that proof with `refl`, which is permitted without K.
  3. The composite then computes. Use the same dependent pattern matching for the first auxiliary law, then lift the canonicalization equation under its surrounding function.
---
Axiom K says all proofs of `x ≡ x` are `refl`. The game (and `felix`, and
the language paper) runs `--without-K`, so that is not available. But for
`ℕ` it is *provable*, because equality is decidable: send every proof
through `_≟_` (`canon`), observe that the result does not depend on the
proof (`canon-const`), and that the round trip is the identity
(`canon-inv`). This is Hedberg's theorem; the standard library packages it
as `Axiom.UniquenessOfIdentityProofs.Decidable⇒UIP`, which
`Shortcut.lagda:90` uses.

The scaffold is in the statement. Fill the three holes.

<!-- @conclusion -->
Now you can read `rewrite dec-yes-irr (k ≟ k) (Decidable⇒UIP.≡-irrelevant _≟_) refl`
in `Shortcut.lagda`: it is this level, applied.
