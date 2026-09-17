---
id: cong-app
index: 2
title: "Function equality and ≗"
learning_goals:
  - "`cong-app : f ≡ g → ∀ x → f x ≡ g x` — equal functions agree everywhere."
  - "`f ≗ g` (pointwise equality) is the equality Spectra2 and felix use for functions."
unlocks:
  lemmas:
    - name: "cong-app"
      agda: "cong-app"
      lean: "congrFun"
    - name: "≗-trans"
      agda: "≗-trans"
      lean: ""
hints:
  - text: "`cong-app`: match the proof against `refl`."
  - text: "`≗-trans p q x = trans (p x) (q x)`."
    hidden: true
---
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
