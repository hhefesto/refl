---
id: right-comm
index: 4
title: "+-right-comm"
learning_goals:
  - "A `≡⟨ ⟩` step can carry a real lemma, not only `refl`."
  - "Plan the intermediate terms of a chain first, then fill in the justifications."
  - "Operator sections: `(x +_)` is `λ y → x + y`."
unlocks:
  lemmas:
    - name: "+-right-comm"
      agda: "+-right-comm"
      lean: "add_right_comm"
      doc: "plus-right-comm.md"
  syntax:
    - name: "sections"
      doc: "sections.md"
hints:
  - text: "No induction this time: rearrange with `+-assoc` and `+-comm`. Plan the chain first: `(x + y) + z` → `x + (y + z)` → `x + (z + y)` → `(x + z) + y`."
  - text: "Each arrow is one `≡⟨ ⟩` step: `+-assoc x y z`, then `cong (x +_) (+-comm y z)`, then `sym (+-assoc x z y)`."
  - text: "The template already has the skeleton; fill the three holes in the brackets."
    hidden: true
---
You met `≡-Reasoning` in the very first level, where every step was `refl`:

```agda
begin
  a ≡⟨ p ⟩
  b ≡⟨ q ⟩
  c ∎
```

with `p : a ≡ b` and `q : b ≡ c`. There the two sides of each step computed to
the same term, so `refl` proved every one of them. Here they do not: the steps
need real lemmas, and the brackets are where those lemmas go.

The template gives you the chain with holes for the justifications.
`cong (x +_) …` applies the section `(x +_)`, that is `λ y → x + y`, to
both sides.

<!-- @conclusion -->
From now on, every proof longer than one `trans` should be a `begin` block.
It is also the shape of Spectra2's `≈ᴹ` reasoning kit (World 11) and of
felix's `≈`-reasoning over setoids (World 15).
