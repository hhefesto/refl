---
example_explanation: |-
  1. Introduce the arbitrary number `n`.
  2. Addition computes on its second argument, so `n + 0` reduces to `n`.
  3. Use `refl` when both sides agree, even with variables still present.
hints:
- hidden: false
  text: A variable can stand for any number; reflexivity does not need to know which
    number it is.
- hidden: true
  text: Read both endpoints of the goal. They are the very same variable, not two
    independently chosen numbers.
- hidden: true
  text: 'Keep the argument in scope: `same x = …`.'
learning_goals:
- '`∀ (x : ℕ) → …` is a function type: the proof takes `x` as an argument.'
- The context panel lists what is in scope inside a hole.
- '`refl` still works when both sides are literally the same expression.'
title: A variable in the way
---
A variable can stand for any number; reflexivity does not need to know which number it is.

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
