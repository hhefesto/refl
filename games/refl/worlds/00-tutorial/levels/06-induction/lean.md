---
example_explanation: |-
  1. Define `copy` by zero/successor recursion.
  2. The zero branch computes.
  3. In the successor branch expose the recursive expression with `change`, then rewrite with `ih`. In the exercise expose addition's recursive equation with `add_succ`.
hints:
- hidden: false
  text: A universal arithmetic law follows the recursive structure of natural numbers.
- hidden: true
  text: Addition is stuck on `x`. Use `induction x with` to get a zero branch and
    a successor branch with a smaller proof.
- hidden: true
  text: Start `induction x with`, followed by `| zero => …` and `| succ n ih => …`.
    In the step, rewrite with `add_succ` and the induction hypothesis.
learning_goals:
- A universal arithmetic law follows the recursive structure of natural numbers.
- Addition is stuck on `x`. Use `induction x with` to get a zero branch and a successor
  branch with a smaller proof.
title: Induction on a natural number
---
A universal arithmetic law follows the recursive structure of natural numbers.

Addition is stuck on `x`. Use `induction x with` to get a zero branch and a successor branch with a smaller proof.

Edit the indented proof directly in the editor. **Check** (`C-c C-l`) checks your current text. Put the cursor on the proof and use **Goal** (`C-c C-,`) to inspect the local context. Replace `sorry` with proof steps; a proof containing `sorry` is unfinished.

<!-- @conclusion -->
You have used this principle in Lean: A universal arithmetic law follows the recursive structure of natural numbers. Keep the technique from the worked example in mind when the surrounding expressions change.
