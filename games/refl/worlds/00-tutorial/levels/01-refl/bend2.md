---
example_explanation: |-
  1. The law states the equality and its type.
  2. `Refl.add(3n, 1n)` computes to `4n`.
  3. The matching definition supplies `{==}`. Use the same constructor for the exercise's different numeric equality.
hints:
- hidden: false
  text: Equality holds when both sides compute to the same value.
- hidden: true
  text: Check turns `?goal` into an inspectable goal. Ask Goal to see the expected
    equality.
- hidden: true
  text: Keep `def two_plus_two():` and replace its hole with the reflexivity expression,
    either directly or using Give.
learning_goals:
- Equality holds when both sides compute to the same value.
- Check turns `?goal` into an inspectable goal. Ask Goal to see the expected equality.
title: Reflexivity with {==}
---
Equality holds when both sides compute to the same value.

Check turns `?goal` into an inspectable goal. Ask Goal to see the expected equality.

Keep the `law` declaration in the fixed statement and edit the matching `def` below it. **Check** (`C-c C-l`) finds named holes such as `?goal`. Select a hole and use **Goal** (`C-c C-,`). Enter a Bend expression in the expression box and press **Give** (`C-c C-SPC`), or edit the definition directly.

<!-- @conclusion -->
You have used this principle in Bend: Equality holds when both sides compute to the same value. Keep the technique from the worked example in mind when the surrounding expressions change.
