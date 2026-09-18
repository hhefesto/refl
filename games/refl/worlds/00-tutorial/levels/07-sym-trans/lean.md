---
example_explanation: |-
  1. Rewrite `a` to `b` using `p`.
  2. Rewrite `c` to `b` using `q`.
  3. The endpoints now agree. The exercise needs a reverse rewrite for its differently oriented first equation.
hints:
- hidden: false
  text: Equality proofs compose only when their intermediate endpoints match.
- hidden: true
  text: The first hypothesis runs from `y` to `x`, while the target starts at `x`.
    A left arrow reverses the rewrite direction.
- hidden: true
  text: Start `rw [← …, …]`, choosing hypotheses so the intermediate terms line up.
learning_goals:
- Equality proofs compose only when their intermediate endpoints match.
- The first hypothesis runs from `y` to `x`, while the target starts at `x`. A left
  arrow reverses the rewrite direction.
title: Orienting and chaining equations
---
Equality proofs compose only when their intermediate endpoints match.

The first hypothesis runs from `y` to `x`, while the target starts at `x`. A left arrow reverses the rewrite direction.

Edit the indented proof directly in the editor. **Check** (`C-c C-l`) checks your current text. Put the cursor on the proof and use **Goal** (`C-c C-,`) to inspect the local context. Replace `sorry` with proof steps; a proof containing `sorry` is unfinished.

<!-- @conclusion -->
You have used this principle in Lean: Equality proofs compose only when their intermediate endpoints match. Keep the technique from the worked example in mind when the surrounding expressions change.
