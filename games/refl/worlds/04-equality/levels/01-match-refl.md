---
id: match-refl
index: 1
title: "Matching on refl"
learning_goals:
  - "`refl` is a constructor, so a proof of an equation can be case split."
  - "Matching a proof against `refl` makes the two sides the same."
  - "Your first lemma from the inventory, proved from nothing."
forbids: ["cong", "congrArg", "rw", "Equal.cong"]
hints:
  - text: "Select the hole, put `p` in the box and press **Case split**. Agda writes `cong′ f refl = ?`."
  - text: "Ask for the **Goal** again. It was `f x ≡ f y`, and now it's `f x ≡ f x`, because `y` has become `x`. What proves a thing equal to itself?"
  - text: "`cong′ f refl = refl`."
---
You've been using `cong`, `sym` and `trans` as tools. This world opens the box and shows
you what they're made of.

Remember the definition of equality from the Tutorial:

```agda
data _≡_ {A : Set} (x : A) : A → Set where
  refl : x ≡ x
```

It's a data type with one constructor, and you already know what to do with a value of a
data type: **Case split** on it. So here is the thing to try. You have `p : x ≡ y` for two
different variables `x` and `y`. There's only one constructor, so `p` has to be `refl`. But
`refl` only proves a thing equal to itself. What does Agda conclude?

To see the answer, ask for the **Goal** before and after you split. Watch `y` in
particular.

This level has you prove `cong` itself, under the name `cong′`. The real `cong` is
forbidden here, as using it would be a little too easy.

<!-- @conclusion -->
That's the secret behind equality. Matching on `refl` tells Agda that the two sides are the
same, so it replaces one by the other everywhere, in the goal and in the context.

`sym`, `trans` and `subst` are all a single line of this.
