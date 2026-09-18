---
example_explanation: |-
  1. Match the equality with `refl`.
  2. Its endpoints become the same, so `P y` becomes `P x`.
  3. Return the supplied evidence. For J, the motive also mentions the equality proof itself.
hints:
- hidden: false
  text: Equality elimination reduces transport to the reflexive case.
- hidden: true
  text: Split the equality proof `p`. Both its endpoint and the proof index in `P`
    change.
- hidden: true
  text: Start `J P d refl = …` and inspect the resulting type of `d`.
learning_goals:
- 'The eliminator J: to prove `P y p` for every proof `p : x ≡ y`, it suffices to
  prove `P x refl`.'
- Matching `refl` unifies `y` with `x`.
title: Pattern matching on refl is J
---
Equality elimination reduces transport to the reflexive case.

Everything you have used about equality is one principle: if `p : x ≡ y`
and `refl` is the only constructor, then matching `p` against `refl` makes
`y` *be* `x`. Stated as a lemma, that is **J**:

```agda
J : (P : ∀ y → x ≡ y → Set) → P x refl → ∀ {y} (p : x ≡ y) → P y p
```

Prove it by case splitting on `p`, and watch the goal change.


<!-- @conclusion -->

`sym`, `trans`, `cong`, `subst` are all instances of J. The `--without-K`
flag on every level restricts *how* this matching may happen (the index
must be a variable); it is what keeps the game compatible with homotopy
type theory and with `felix`, which is entirely `--without-K`.
