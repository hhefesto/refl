---
id: conjunction
index: 2
title: "And is a pair"
learning_goals:
  - "`A × B` is a record with fields `proj₁ : A` and `proj₂ : B`; `a , b` builds one."
  - "Case split on a pair to name its parts."
unlocks:
  lemmas:
    - name: "×-comm"
      agda: "×-comm"
      lean: "And.symm"
      doc: "and-comm.md"
hints:
  - text: "**Case split** on `p`. Agda writes `×-comm (proj₃ , proj₄) = ?`, so `proj₃ : A` and `proj₄ : B`. Rename them if you like, to `(a , b)` for example."
  - text: "The goal is `B × A`. **Refine** with an empty box gives `? , ?`, one hole for each side."
  - text: "`×-comm (a , b) = b , a`. Also fine: `×-comm p = proj₂ p , proj₁ p`."
---
To prove "A and B" you need a proof of `A` and a proof of `B`, so a proof of `A × B` is
a **pair** of proofs:

```agda
record _×_ (A B : Set) : Set where
  constructor _,_
  field
    proj₁ : A
    proj₂ : B
```

You build a pair with `_,_`, written `a , b`. To use one, either project out a part
with `proj₁ p` and `proj₂ p`, or take it apart with **Case split**.

The statement says "and" is commutative. The template names the hypothesis `p`. Try
**Case split** on `p`, and don't be thrown by what you get: Agda names the parts after
the record's fields. `proj₁` and `proj₂` are already taken by the projections, so it
picks the next free names, `proj₃` and `proj₄`. These are just variables. Rename them
in the editor to whatever you want, then **Check** again.

<!-- @conclusion -->
`_×_` is a *record*, and case splitting on a record value gives its constructor pattern.
Agda's made-up names are a fact of life, so renaming them is a normal part of writing a
proof.
