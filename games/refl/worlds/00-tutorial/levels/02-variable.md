---
id: variable
index: 2
title: "A variable in the way"
learning_goals:
  - "`∀ (x : ℕ) → …` is a function type: the proof takes `x` as an argument."
  - "The context panel lists what is in scope inside a hole."
  - "`refl` still works when both sides are literally the same expression."
hints:
  - text: "The statement is a function type. The template already takes the argument on the left of `=`: `same x = ?`. Check the file, then ask for the **Goal**: the context shows `x : ℕ` and the goal is `x ≡ x`."
  - text: "Give `refl`."
    hidden: true
---
`∀ (x : ℕ) → x ≡ x` reads "for every natural number `x`, `x` equals `x`". In
Agda a *for all* is a function type: a proof is a function that takes `x` and
returns a proof of `x ≡ x`.

Look at the **Goal** panel after checking: it has two parts. Above the line is
the **context** (the things you may use: here `x : ℕ`), below it is the
**goal type**.

<!-- @conclusion -->
Arguments on the left of `=` are how you "introduce" a for-all. You will also
meet the anonymous form `λ x → …` on the right-hand side; they mean the same
thing.
