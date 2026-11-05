---
id: reading-analog
index: 9
title: "Reading: analog₁ (Timely Computation)"
learning_goals:
  - "`→` associates to the right: `A → B → C` is `A → (B → C)`."
  - "A function returning a function can take the extra argument on the left of `=`."
  - "Two definitions that differ only in this way are equal by `refl`."
hints:
  - text: "`analog₁ δ h x̃` returns a function of `t`, written with a `λ`. The first hole is the body of that `λ`; copy the names from the statement."
  - text: "The first hole is `h (x̃ (t + δ))`. Fill it and press **Check**: now the second hole's goal has the same term on both sides."
  - text: "The second hole is `refl`."
---
Every world ends with a **reading level**: a real definition from published code,
simplified, with something removed. These are the kind of definitions this game
wants you to be able to read.

This one comes from *Timely Computation*, Conal Elliott's ICFP 2023 paper on
circuits and time. Simplified to `ℕ` and shifted forward instead of back, it is a
one-input analog gate. Given a delay `δ`, a function `h` on values and an input
signal `x̃` (a function of time), the output signal at time `t` is `h` applied to
the input at time `t + δ`:

```agda
analog₁ δ h x̃ = λ t → h (x̃ (t + δ))
```

Now read its type, `ℕ → (ℕ → ℕ) → (ℕ → ℕ) → (ℕ → ℕ)`. It ends in a function type,
and `→` associates to the right, so that last pair of parentheses changes nothing.
This is the same type as a function of **four** arguments. So you can also write
it with `t` on the left of `=`, as the first hole sets up.

Fill the two holes: define `analog₁′` that way, then prove that the two agree. Do
them in order, because until the first hole is filled, the second one's goal
refers to it as `?0`.

<!-- @conclusion -->
A function of three arguments that returns a function, and a function of four
arguments: to the checker they are the same thing, and you have just proved it.
Papers switch between the two without comment, and now you can follow them.

**Tutorial World complete.** Addition World is next: `suc-+`, `+-comm`, `+-assoc`,
and chains whose steps carry real lemmas.
