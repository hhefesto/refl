---
example_explanation: |-
  1. Name the input equation `h`.
  2. `rw [h]` replaces `a` by `b` inside the addition.
  3. The identical endpoints close. In the exercise rewriting takes place under `succ` instead.
hints:
- hidden: false
  text: Equal inputs remain equal when passed to the same function.
- hidden: true
  text: 'The local context contains `h : x = y`. Rewriting with it makes the successor
    expressions identical.'
- hidden: true
  text: Use the shape `rw […]` with the hypothesis from the context.
learning_goals:
- Equal inputs remain equal when passed to the same function.
- 'The local context contains `h : x = y`. Rewriting with it makes the successor expressions
  identical.'
title: Equality under a function
---
Equal inputs remain equal when passed to the same function.

The local context contains `h : x = y`. Rewriting with it makes the successor expressions identical.

Edit the indented proof directly in the editor. **Check** (`C-c C-l`) checks your current text. Put the cursor on the proof and use **Goal** (`C-c C-,`) to inspect the local context. Replace `sorry` with proof steps; a proof containing `sorry` is unfinished.

<!-- @conclusion -->
You have used this principle in Lean: Equal inputs remain equal when passed to the same function. Keep the technique from the worked example in mind when the surrounding expressions change.
