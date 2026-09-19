---
title: "+-right-comm and ≡-Reasoning"
learning_goals:
  - "`begin … ≡⟨ proof ⟩ … ∎` writes a chain of equations with the intermediate terms visible."
  - "`≡⟨⟩` is a step that holds by computation."
  - "Operator sections: `(x +_)` is `λ y → x + y`."
hints:
  - text: "No induction this time: rearrange with `+-assoc` and `+-comm`. Plan the chain first: `(x + y) + z` → `x + (y + z)` → `x + (z + y)` → `(x + z) + y`."
  - text: "Each arrow is one `≡⟨ ⟩` step: `+-assoc x y z`, then `cong (x +_) (+-comm y z)`, then `sym (+-assoc x z y)`."
  - text: "The template already has the skeleton; fill the three holes in the brackets."
    hidden: true
example_explanation: |-
  1. Write the start, intermediate and final terms.
  2. Justify each edge by lifting a supplied equation.
  3. `begin` chains the edges. In the exercise choose intermediate sums so each edge is one available arithmetic lemma.
---
`≡-Reasoning` gives you

```agda
begin
  a ≡⟨ p ⟩
  b ≡⟨ q ⟩
  c ∎
```

where `p : a ≡ b` and `q : b ≡ c`. It is defined in the prelude as plain
functions (`begin_`, `_≡⟨_⟩_`, `_∎`) built from `trans` — open the
inventory entry to see them. A step `≡⟨⟩` with nothing inside means "by
computation".

The template gives you the chain with holes for the justifications.
`cong (x +_) …` applies the section `(x +_)`, that is `λ y → x + y`, to
both sides.

<!-- @conclusion -->
From now on, every proof longer than one `trans` should be a `begin` block.
It is also the shape of Spectra2's `≈ᴹ` reasoning kit (World 11) and of
felix's `≈`-reasoning over setoids (World 15).
