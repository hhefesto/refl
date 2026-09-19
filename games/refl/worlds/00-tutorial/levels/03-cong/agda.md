---
title: "cong"
learning_goals:
  - "Hypotheses are just arguments; name them on the left of `=`."
  - "`cong f : x ≡ y → f x ≡ f y` applies a function to both sides of an equation."
  - "Curly braces `{x y : ℕ}` mark implicit arguments Agda fills in itself."
hints:
  - text: "The hypothesis `x ≡ y` is an argument. The template names it `h`. Ask for the goal: `suc x ≡ suc y` with `h : x ≡ y` in the context."
  - text: "You need to apply `suc` to both sides of `h`. The lemma for that is `cong`: `cong suc h : suc x ≡ suc y`."
    hidden: true
example_explanation: |-
  1. Name the input equation `h`.
  2. The surrounding function is `λ n → n + 2`.
  3. `cong` applies that function to both endpoints. Identify the exercise's surrounding function in the same way.
---
An implication `A → B` is a function type too, so a hypothesis is an argument.
Here the hypothesis `x ≡ y` is called `h` in the template.

The braces in `∀ {x y : ℕ}` make `x` and `y` **implicit**: you do not write
them on the left of `=`, Agda infers them from `h`.

New lemma, in your inventory from now on:

```agda
cong : ∀ {A B : Set} (f : A → B) {x y : A} → x ≡ y → f x ≡ f y
```

"If `x ≡ y` then `f x ≡ f y`". Read the type: the first explicit argument is
the function, the last is the equation.

<!-- @conclusion -->
`cong` is the workhorse of every inductive step you will ever write:
`cong suc (induction-hypothesis)`.
