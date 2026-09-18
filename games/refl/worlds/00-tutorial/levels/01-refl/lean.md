---
example_explanation: |-
  1. The declaration fixes both endpoints.
  2. Addition computes to `4` on the left.
  3. `rfl` checks that the endpoints agree. The exercise uses different numerals, with the same computation test.
hints:
- hidden: false
  text: Equality holds when both sides reduce to the same value.
- hidden: true
  text: Check the file, place the cursor at `sorry`, then ask Goal. The target is
    an equality of computed numbers.
- hidden: true
  text: Replace `sorry` with the reflexivity tactic, keeping the proof indented under
    `by`.
learning_goals:
- Equality holds when both sides reduce to the same value.
- Check the file, place the cursor at `sorry`, then ask Goal. The target is an equality
  of computed numbers.
title: Reflexivity with rfl
---
Equality holds when both sides reduce to the same value.

Check the file, place the cursor at `sorry`, then ask Goal. The target is an equality of computed numbers.

Edit the indented proof directly in the editor. **Check** (`C-c C-l`) checks your current text. Put the cursor on the proof and use **Goal** (`C-c C-,`) to inspect the local context. Replace `sorry` with proof steps; a proof containing `sorry` is unfinished.

<!-- @conclusion -->
You have used this principle in Lean: Equality holds when both sides reduce to the same value. Keep the technique from the worked example in mind when the surrounding expressions change.
