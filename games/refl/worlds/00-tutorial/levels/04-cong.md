---
id: cong
index: 4
title: "cong"
learning_goals:
  - "Hypotheses are just arguments; name them on the left of `=`."
  - "`cong f : x ≡ y → f x ≡ f y` applies a function to both sides of an equation."
  - "Curly braces `{x y : ℕ}` mark implicit arguments Agda fills in itself."
unlocks:
  lemmas:
    - name: "cong"
      agda: "cong"
      lean: "congrArg"
      bend2: "Equal.cong"
      doc: "cong.md"
hints:
  - text: "Ask for the **Goal**. The context has `h : x ≡ y` and the goal is `suc x ≡ suc y`. How does the goal differ from `h`?"
  - text: "It is `h` with `suc` applied to both sides, and that is what `cong` does. Its first argument is the function, its last is the equation: `cong suc h`."
---
An implication `A → B` is a function type too, so a hypothesis is just an
argument. Here the hypothesis `x ≡ y` is called `h` in the template, and it will
be in the context when you ask for the **Goal**.

The braces in `∀ {x y : ℕ}` make `x` and `y` **implicit**: you do not write them
on the left of `=`, because Agda works them out from `h`. They still show up in
the context.

This level also gives you your first real tool, a lemma that stays in your
inventory from now on:

```agda
cong : ∀ {A B : Set} (f : A → B) {x y : A} → x ≡ y → f x ≡ f y
```

Read the type from the left. You give it a function `f` and a proof that `x`
equals `y`, and it returns a proof that `f x` equals `f y`: if two things are
equal, applying the same function to both keeps them equal. The first explicit
argument is the function and the last is the equation.

Now compare your goal with your hypothesis. Which function has been applied to
both sides?

<!-- @conclusion -->
`cong` is the workhorse of every inductive step you will ever write:
`cong suc (induction-hypothesis)`.
