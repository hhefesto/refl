---
id: hedberg
index: 12
title: "Hedberg: decidable equality gives UIP"
learning_goals:
  - "Under `--without-K`, `p ≡ q` for two proofs of `x ≡ y` is not automatic."
  - "With decidable equality it is provable: canonicalise every proof through the decision."
  - "Filling in a chain whose intermediate terms are given."
unlocks:
  lemmas:
    - name: "≡-irrelevant"
      agda: "≡-irrelevant"
      lean: "Subsingleton.elim"
      doc: "uip.md"
hints:
  - text: "The first hole is the equation between its two lines, `p ≡ trans (sym (canon refl)) (canon p)`. That's `canon-inv p`, pointing the other way."
  - text: "The last hole is `canon-inv q`, as it stands. The middle one changes `canon p` to `canon q` under `trans (sym (canon refl))`. That's `canon-const` under a `cong`."
  - text: "The three holes are `sym (canon-inv p)`, `cong (trans (sym (canon refl))) (canon-const p q)` and `canon-inv q`."
---
Here's the theorem: any two proofs of the same equation on `ℕ` are equal.

```agda
≡-irrelevant : ∀ {x y : ℕ} (p q : x ≡ y) → p ≡ q
```

This property is called **UIP**, for *uniqueness of identity proofs*. **Axiom K** would give it to you for every type at
once, but this game runs `--without-K`, so that isn't available. For `ℕ` you don't need it: this is **Hedberg's theorem**,
which says that any type with decidable equality has UIP.

You did the hard work in the last two levels. `canon-inv` says that any proof can be rebuilt from its canonical version, and
`canon-const` says that every proof has the same canonical version. Put the two together:

1. Start from `p`, and rewrite it as `p` rebuilt from `canon p`.
2. Change `canon p` to `canon q`. They're equal, whatever `p` and `q` are.
3. What you have now is `q` rebuilt from `canon q`. So that's `q`.

The template has those three steps written out as a chain, and each hole is one short expression, using lemmas that are in scope.
Each hole has to prove the equation between the line above it and the line below it, so read those. **Goal** will also tell you, but it
unfolds `canon` into something much longer. And remember that a lemma may point the wrong way.

<!-- @conclusion -->
You've proved a real theorem about the structure of proofs. In the standard library, it's
`Axiom.UniquenessOfIdentityProofs.Decidable⇒UIP`. When you see `≡-irrelevant` in a proof, it means someone has two proofs of
the same fact on a decidable type and needs them to be the same one.
