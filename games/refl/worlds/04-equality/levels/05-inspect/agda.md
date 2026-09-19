---
title: "The old inspect idiom"
learning_goals:
  - "Before `with … in`, the same effect was `with e | inspect f x` and a pattern `[ eq ]`."
  - "Recognising it in older code."
hints:
  - text: "Same proof as before, in the old clothes: `with n ≡ᵇ 0 | inspect (n ≡ᵇ_) 0` and then `... | true | [ eq ]`."
  - text: "`... | true | [ eq ] = ⊥-elim (h (≡ᵇ⇒≡ n 0 eq))`; `... | false | _ = refl`."
    hidden: true
example_explanation: |-
  1. Store a reflexive equation in an indexed record.
  2. Abstract the test alongside that record.
  3. Unpack the equation and reflect the true result into a contradiction; the false branch is reflexive. The exercise uses `inspect` and `[ eq ]` for this same bookkeeping.
---
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
