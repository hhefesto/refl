---
id: impossible
index: 8
title: "Impossible equations"
learning_goals:
  - "`x ≢ y` unfolds to `x ≡ y → ⊥`."
  - "Different constructors can never be equal, and Agda knows it."
  - "`λ ()` is a function whose argument can't exist."
unlocks:
  syntax:
    - name: "λ ()"
      bend2: "Logic.zero_ne_succ"
      lean: "nofun"
      doc: "absurd-lambda.md"
hints:
  - text: "Ask for the **Goal**: `0 ≡ suc n → ⊥`. It's a function type, so you need a function. Its argument would be a proof that `zero` equals `suc n`. Can there be one?"
  - text: "There can't, and `λ ()` says so: a function with no cases, because its argument can't exist. Give `λ ()`."
---
You now have enough logic to say two numbers are *different*. `x ≢ y` means `¬ (x ≡ y)`,
and you know what `¬` unfolds to, so this is a function that takes a proof of `x ≡ y` and
returns `⊥`.

Why should `zero ≢ suc n` hold? Think about how a proof of an equation is made. There's
one constructor, `refl`, and it only fits when the two sides compute to the same term.
But `zero` and `suc n` are built with different constructors, so no amount of computing
can ever bring them together. There can't be a `refl` for them, and so there's no proof
of that equation at all.

Agda knows this. In an earlier level you saw the absurd pattern `()`, which is what Agda
writes for an argument with no possible cases. An anonymous function can do the same:

```agda
λ ()
```

This is a function that needs no body, because its argument can't exist. It only type-checks
when Agda can see that this is true.

<!-- @conclusion -->
Every proof that two constructors differ looks like this. Agda checks it for you, by
trying to unify the two sides and failing. The next level puts this to use.
