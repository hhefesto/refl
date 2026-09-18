---
example_explanation: |-
  1. Store a reflexive equation in an indexed record.
  2. Abstract the test alongside that record.
  3. Unpack the equation and reflect the true result into a contradiction; the false branch is reflexive. The exercise uses `inspect` and `[ eq ]` for this same bookkeeping.
hints:
- hidden: false
  text: An indexed record can preserve the link between an expression and its matched
    value.
- hidden: true
  text: Abstract the test and its inspection record together. Unpack `[ eq ]` to recover
    the equation.
- hidden: true
  text: Use two `with` columns; match the true branch with `true | [ eq ]`.
learning_goals:
- Before `with … in`, the same effect was `with e | inspect f x` and a pattern `[
  eq ]`.
- Recognising it in older code.
title: The old inspect idiom
---
An indexed record can preserve the link between an expression and its matched value.

Older code (and `market/agda/Market/Serialize.agda:94` in
formalTransformer) remembers a test result with a small record:

```agda
record Reveal_·_is_ {A B : Set} (f : A → B) (x : A) (y : B) : Set where
  constructor [_]
  field eq : f x ≡ y

inspect : ∀ {A B : Set} (f : A → B) (x : A) → Reveal f · x is f x
inspect f x = [ refl ]
```

You `with f x | inspect f x` and match the second column against
`[ eq ]`. Reprove the previous lemma (here `g-nonzero`, for the same function called `g`) this way.


<!-- @conclusion -->

When you see `inspect` and `[_]` in a file, read it as `with … in eq`. The
standard library kept the old form under `Relation.Binary.PropositionalEquality`
for a long time; `with … in` is the modern syntax.
