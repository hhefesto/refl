---
id: subst
index: 8
title: "subst and transport"
learning_goals:
  - "`subst P p : P x → P y` transports along `p : x ≡ y`."
  - "Choosing the motive `P` is the whole game: `(x ≡_)`, `(_+ z ≡ w)`, …"
unlocks:
  lemmas:
    - name: "subst"
      agda: "subst"
      lean: "Eq.subst"
      doc: "subst.md"
forbids: ["trans"]
hints:
  - text: "Transport `p : x ≡ y` along `q : y ≡ z` in its right endpoint: the motive is `(x ≡_)`."
  - text: "`trans′ p q = subst (x ≡_) q p` (you may need `{x = x}` or a lambda motive `(λ w → x ≡ w)`)."
    hidden: true
---
`subst P p` moves a proof of `P x` to a proof of `P y`. The art is
picking `P` (the *motive*), usually as a section. Reprove `trans` with
`subst` instead of pattern matching — `trans` itself is forbidden here.

<!-- @conclusion -->
`subst₂` (two equations at once) is what `blocks-ext` in `Block.lagda:93`
uses to transport across two index equations; the motive there is
`(λ x y → M x y ≡ N x y)`.
