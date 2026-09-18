---
example_explanation: |-
  1. Define `copy` by recursion.
  2. Its zero case computes.
  3. In the successor case transport the smaller equality under `1n+_`, then use `{==}`. The exercise follows the same pattern for addition instead of copying.
hints:
- hidden: false
  text: A proof for every number follows zero and successor cases, with recursion
    on the predecessor.
- hidden: true
  text: Edit the definition to `match x:` with `case 0n:` and `case 1n+p:`. Only the
    predecessor `p` is smaller.
- hidden: true
  text: 'The successor branch starts `%zero_add(p) : {1n+Refl.add(0n, p) == 1n+_ :
    Nat}`; inspect the equality after transport.'
learning_goals:
- A proof for every number follows zero and successor cases, with recursion on the
  predecessor.
- Edit the definition to `match x:` with `case 0n:` and `case 1n+p:`. Only the predecessor
  `p` is smaller.
title: Induction by matching a natural number
---
A proof for every number follows zero and successor cases, with recursion on the predecessor.

Edit the definition to `match x:` with `case 0n:` and `case 1n+p:`. Only the predecessor `p` is smaller.

Keep the `law` declaration in the fixed statement and edit the matching `def` below it. **Check** (`C-c C-l`) finds named holes such as `?goal`. Select a hole and use **Goal** (`C-c C-,`). Enter a Bend expression in the expression box and press **Give** (`C-c C-SPC`), or edit the definition directly.

<!-- @conclusion -->
You have used this principle in Bend: A proof for every number follows zero and successor cases, with recursion on the predecessor. Keep the technique from the worked example in mind when the surrounding expressions change.
