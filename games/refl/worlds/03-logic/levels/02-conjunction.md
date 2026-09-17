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
  - text: "Case split on `p`: it becomes `(a , b)`. Then build the swapped pair with `,`."
  - text: "`×-comm (a , b) = b , a`. Also fine: `×-comm p = proj₂ p , proj₁ p`."
    hidden: true
---
A proof of `A × B` is a pair. The constructor is `_,_` (mixfix: `a , b`),
the projections are `proj₁`, `proj₂`.

<!-- @conclusion -->
`_×_` is a *record*; case splitting on a record value gives its constructor
pattern. Records are World 8's subject; here they are just pairs.
