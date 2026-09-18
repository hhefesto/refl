---
example_explanation: |-
  1. `shift k` returns a function.
  2. Move the lambda's argument to the left of `=` to obtain `shift′`.
  3. Applying either definition computes to the same expression. Transfer this argument movement to the signal function in the exercise.
hints:
- hidden: false
  text: A function returning a function can instead accept its final argument explicitly.
- hidden: true
  text: 'Apply the returned lambda to `t`. Preserve the order: shift time, sample
    the input, then apply `h`.'
- hidden: true
  text: Define `analog₁′ δ h x̃ t = h (…)`, then compare both sides of `analog-same`
    by computation.
learning_goals:
- '`→` associates to the right: `A → B → C` is `A → (B → C)`.'
- A function returning a function can take the extra argument on the left of `=`.
- Two definitions that differ only in this way are equal by `refl`.
title: 'Reading: analog₁ (Timely Computation)'
---
A function returning a function can instead accept its final argument explicitly.

Every world ends with a **reading level**: a real definition from the code
this game leads to, with something removed.

From *Timely Computation* (ICFP 2023), simplified to `ℕ` and shifted forward
instead of back, a one-input analog gate: given a delay `δ`, a function `h` on
values, and an input signal `x̃` (a function of time), the output signal at
time `t` is `h` applied to the input at time `t + δ`:

```agda
analog₁ δ h x̃ = λ t → h (x̃ (t + δ))
```

The type `ℕ → (ℕ → ℕ) → (ℕ → ℕ) → (ℕ → ℕ)` ends in a function type, and
`→` associates to the right. So the same thing can be written with `t` as a
fourth argument on the left of `=`. Define `analog₁′` that way, then prove
the two agree.


<!-- @conclusion -->

This was the note in the study file for Timely Computation: `analog₁ δ h x̃ t
= …` and `analog₁ δ h = λ x̃ → λ t → …` are identical. Now you have proved it.

**Tutorial World complete.** Addition World is next: `+-suc`, `+-comm`,
`+-assoc`, and equational reasoning.
