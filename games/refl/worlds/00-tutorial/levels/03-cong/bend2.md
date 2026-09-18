---
example_explanation: |-
  1. The law gives equality evidence `h`.
  2. Supply the shared surrounding function to `Equal.cong`.
  3. It lifts the evidence to the function's outputs. For the exercise use the successor function instead of addition by two.
hints:
- hidden: false
  text: Applying the same function to equal inputs preserves their equality.
- hidden: true
  text: The context supplies `h`. `Equal.cong` needs the input type, output type,
    function, both endpoints, and the equality evidence.
- hidden: true
  text: Use `Equal.cong(Nat, Nat, n => …, x, y, h)`, filling in the function from
    the target.
learning_goals:
- Applying the same function to equal inputs preserves their equality.
- The context supplies `h`. `Equal.cong` needs the input type, output type, function,
  both endpoints, and the equality evidence.
title: Equality under a function
---
Applying the same function to equal inputs preserves their equality.

The context supplies `h`. `Equal.cong` needs the input type, output type, function, both endpoints, and the equality evidence.

Keep the `law` declaration in the fixed statement and edit the matching `def` below it. **Check** (`C-c C-l`) finds named holes such as `?goal`. Select a hole and use **Goal** (`C-c C-,`). Enter a Bend expression in the expression box and press **Give** (`C-c C-SPC`), or edit the definition directly.

<!-- @conclusion -->
You have used this principle in Bend: Applying the same function to equal inputs preserves their equality. Keep the technique from the worked example in mind when the surrounding expressions change.
