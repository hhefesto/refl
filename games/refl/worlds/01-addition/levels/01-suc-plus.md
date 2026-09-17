---
id: suc-plus
index: 1
title: "suc-+"
learning_goals:
  - "Induction on the argument the definition recurses on."
  - "`suc x + y ≡ suc (x + y)`: the mirror image of the defining clause `x + suc y = suc (x + y)`."
unlocks:
  lemmas:
    - name: "suc-+"
      agda: "suc-+"
      lean: "succ_add"
      doc: "suc-plus.md"
hints:
  - text: "Which argument does `_+_` recurse on? Case split on that one (`y`)."
  - text: "`suc-+ x zero = refl` and `suc-+ x (suc y) = cong suc (suc-+ x y)`."
    hidden: true
---
The definition of `_+_` says what `x + suc y` is. This lemma says what
`suc x + y` is, and needs induction on `y` because that is the argument
that computes.

Same recipe as `zero-+`: case split, `refl`, `cong suc` of the inductive
call.

<!-- @conclusion -->
NNG4 calls this `succ_add`. With `zero-+` and `suc-+` you can now prove
commutativity.
