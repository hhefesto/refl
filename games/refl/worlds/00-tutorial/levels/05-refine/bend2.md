---
example_explanation: |-
  1. Unfold each addition on the right numeral.
  2. Each side reduces to two successors of `n`.
  3. `{==}` checks the equality. The exercise uses different nested numerals with the same reduction rule.
hints:
- hidden: false
  text: A variable does not block computations controlled by known right arguments.
- hidden: true
  text: Expand the definition of `Refl.add` on each right numeral. Both sides become
    successors of the same `x`.
- hidden: true
  text: Keep `def three_steps(x):` and use the constructor for equal computed endpoints
    in its body.
learning_goals:
- A variable does not block computations controlled by known right arguments.
- Expand the definition of `Refl.add` on each right numeral. Both sides become successors
  of the same `x`.
title: Computation under nested addition
---
A variable does not block computations controlled by known right arguments.

Expand the definition of `Refl.add` on each right numeral. Both sides become successors of the same `x`.

Keep the `law` declaration in the fixed statement and edit the matching `def` below it. **Check** (`C-c C-l`) finds named holes such as `?goal`. Select a hole and use **Goal** (`C-c C-,`). Enter a Bend expression in the expression box and press **Give** (`C-c C-SPC`), or edit the definition directly.

<!-- @conclusion -->
You have used this principle in Bend: A variable does not block computations controlled by known right arguments. Keep the technique from the worked example in mind when the surrounding expressions change.
