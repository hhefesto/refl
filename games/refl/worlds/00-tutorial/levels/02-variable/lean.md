---
example_explanation: |-
  1. Introduce an arbitrary `n` in the declaration.
  2. Addition on the right zero computes to `n`.
  3. Use `rfl`. The exercise is already reflexive without even unfolding addition.
hints:
- hidden: false
  text: Reflexivity works for arbitrary values; it does not need a concrete numeral.
- hidden: true
  text: The goal has the same variable at both endpoints. You do not need induction
    or a case distinction.
- hidden: true
  text: Keep `by` in the fixed declaration and put one tactic in the editor in place
    of `sorry`.
learning_goals:
- Reflexivity works for arbitrary values; it does not need a concrete numeral.
- The goal has the same variable at both endpoints. You do not need induction or a
  case distinction.
title: Reflexivity with variables
---
Reflexivity works for arbitrary values; it does not need a concrete numeral.

The goal has the same variable at both endpoints. You do not need induction or a case distinction.

Edit the indented proof directly in the editor. **Check** (`C-c C-l`) checks your current text. Put the cursor on the proof and use **Goal** (`C-c C-,`) to inspect the local context. Replace `sorry` with proof steps; a proof containing `sorry` is unfinished.

<!-- @conclusion -->
You have used this principle in Lean: Reflexivity works for arbitrary values; it does not need a concrete numeral. Keep the technique from the worked example in mind when the surrounding expressions change.
