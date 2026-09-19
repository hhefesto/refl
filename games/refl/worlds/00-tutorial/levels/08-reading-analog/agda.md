---
title: "Reading: analog₁ (Timely Computation)"
learning_goals:
  - "`→` associates to the right: `A → B → C` is `A → (B → C)`."
  - "A function returning a function can take the extra argument on the left of `=`."
  - "Two definitions that differ only in this way are equal by `refl`."
hints:
  - text: "`analog₁ δ h x̃` returns a function of `t`, written with a `λ`. `analog₁′` must be the same function, but with `t` as a fourth argument on the left of `=`: `analog₁′ δ h x̃ t = h (x̃ (t + δ))`."
  - text: "Once `analog₁′` is defined that way, both sides of `analog-same` compute to `h (x̃ (t + δ))`, so the proof is `refl`. Give `refl` in the second hole."
    hidden: true
example_explanation: |-
  1. `shift k` returns a function.
  2. Move the lambda's argument to the left of `=` to obtain `shift′`.
  3. Applying either definition computes to the same expression. Transfer this argument movement to the signal function in the exercise.
---
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
