---
title: "suc-+"
learning_goals:
  - "Induction on the argument the definition recurses on."
  - "`suc x + y ≡ suc (x + y)`: the mirror image of the defining clause `x + suc y = suc (x + y)`."
hints:
  - text: "Which argument does `_+_` recurse on? Case split on that one (`y`)."
  - text: "`suc-+ x zero = refl` and `suc-+ x (suc y) = cong suc (suc-+ x y)`."
    hidden: true
example_explanation: |-
  1. `_+_` recurses on its second argument, so `y` is the variable to split: Case split on `y`.
  2. `y = zero`: both sides compute to `suc x`, so `refl`.
  3. `y = suc y`: both sides compute to `suc (…)` of the smaller statement; `cong suc (example x y)` lifts the recursive call.
  The exercise has the same shape: split the second argument, `refl` at zero, `cong suc` of the recursive call at `suc`.
---
The definition of `_+_` says what `x + suc y` is. This lemma says what
`suc x + y` is, and needs induction on `y` because that is the argument
that computes.

Same recipe as `zero-+`: case split, `refl`, `cong suc` of the inductive
call.

<!-- @conclusion -->
NNG4 calls this `succ_add`. With `zero-+` and `suc-+` you can now prove
commutativity.
