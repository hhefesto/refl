---
example_explanation: |-
  1. Introduce a point `x`.
  2. Apply the pointwise hypothesis at that point.
  3. Reverse the resulting equality. In the exercise compose pointwise proofs only after applying them to the same argument.
hints:
- hidden: false
  text: Pointwise equality talks about values at each input, without assuming function
    extensionality.
- hidden: true
  text: Match the function equality in the first lemma. In the second, apply both
    hypotheses to the same `x`.
- hidden: true
  text: The second proof has shape `trans (p …) (q …)`.
learning_goals:
- '`cong-app : f ≡ g → ∀ x → f x ≡ g x` — equal functions agree everywhere.'
- '`f ≗ g` (pointwise equality) is the equality Spectra2 and felix use for functions.'
title: Function equality and ≗
---
Pointwise equality talks about values at each input, without assuming function extensionality.

Two lemmas. First `cong-app`, the mirror of `cong`. Then transitivity of
**pointwise** equality `_≗_`, defined in the statement:

```agda
f ≗ g = ∀ x → f x ≡ g x
```

Agda has no function extensionality by default, so `f ≗ g` does not give
`f ≡ g`; the other direction (`cong-app`) does hold. Most real
developments therefore state equalities of functions and matrices as `≗`
(`Matrix.lagda`'s `_≈ᴹ_` is pointwise in two indices).


<!-- @conclusion -->

When you read `_≗_` in `felix`'s `Instances/Function/Raw.agda`
(`equivalent : Equivalent ℓ _⇾_` with `_≈_ = _≗_`), this is it.
