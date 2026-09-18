---
example_explanation: |-
  1. Rewrite `n` to `4`.
  2. The resulting equality is `4 + 1 = 5`.
  3. `rfl` computes the addition. Transfer this sequence using the exercise's own hypothesis and constants.
hints:
- hidden: false
  text: An equality hypothesis can expose an arithmetic computation.
- hidden: true
  text: Use `h` to substitute the numeral for `x`. Inspect the remaining goal after
    that substitution.
- hidden: true
  text: Begin with `rw […]`; if arithmetic remains, follow with the reflexivity tactic
    on a new indented line.
learning_goals:
- An equality hypothesis can expose an arithmetic computation.
- Use `h` to substitute the numeral for `x`. Inspect the remaining goal after that
  substitution.
title: Substitution before computation
---
An equality hypothesis can expose an arithmetic computation.

Use `h` to substitute the numeral for `x`. Inspect the remaining goal after that substitution.

Edit the indented proof directly in the editor. **Check** (`C-c C-l`) checks your current text. Put the cursor on the proof and use **Goal** (`C-c C-,`) to inspect the local context. Replace `sorry` with proof steps; a proof containing `sorry` is unfinished.

<!-- @conclusion -->
You have used this principle in Lean: An equality hypothesis can expose an arithmetic computation. Keep the technique from the worked example in mind when the surrounding expressions change.
