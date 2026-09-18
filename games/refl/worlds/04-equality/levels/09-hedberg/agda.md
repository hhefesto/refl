---
example_explanation: |-
  1. Generalize both endpoints of the equality proof.
  2. Match that proof with `refl`, which is permitted without K.
  3. The composite then computes. Use the same dependent pattern matching for the first auxiliary law, then lift the canonicalization equation under its surrounding function.
hints:
- hidden: false
  text: Canonicalization proves uniqueness by sending every equality proof through
    the same decision.
- hidden: true
  text: First prove the cancellation law by matching equality. Then use it for the
    canonical round trip, and lift `canon-const` through the surrounding composite.
- hidden: true
  text: The central chain step has shape `cong (trans (sym (canon refl))) …`.
learning_goals:
- Under `--without-K`, `p ≡ q` for two proofs of `x ≡ y` is not automatic.
- 'With decidable equality it is provable: canonicalise every proof through the decision.'
- Reading a scaffolded proof and filling the gaps.
title: 'Hedberg: decidable equality gives UIP'
---
Canonicalization proves uniqueness by sending every equality proof through the same decision.

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
