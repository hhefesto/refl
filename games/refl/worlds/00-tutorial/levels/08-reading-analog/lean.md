---
example_explanation: |-
  1. `shifted k` returns a lambda.
  2. `shifted'` names the lambda's argument explicitly.
  3. Applying either computes to `n + k`, so `rfl` works. The exercise additionally samples and transforms a signal, but argument movement is the same.
hints:
- hidden: false
  text: A function returning a function may instead accept one more explicit argument.
- hidden: true
  text: Apply both definitions to `t`. Their bodies use the same shifted input and
    outer function.
- hidden: true
  text: The two definitions are already supplied in Lean. Replace the theorem's `sorry`
    with a proof by computation.
learning_goals:
- A function returning a function may instead accept one more explicit argument.
- Apply both definitions to `t`. Their bodies use the same shifted input and outer
  function.
title: Reading a function-valued definition
---
A function returning a function may instead accept one more explicit argument.

Apply both definitions to `t`. Their bodies use the same shifted input and outer function.

Edit the indented proof directly in the editor. **Check** (`C-c C-l`) checks your current text. Put the cursor on the proof and use **Goal** (`C-c C-,`) to inspect the local context. Replace `sorry` with proof steps; a proof containing `sorry` is unfinished.

<!-- @conclusion -->
You have used this principle in Lean: A function returning a function may instead accept one more explicit argument. Keep the technique from the worked example in mind when the surrounding expressions change.
