---
example_explanation: |-
  1. Bind the arbitrary number in the law.
  2. Addition on the right zero computes.
  3. `{==}` proves the resulting reflexive equality. The exercise needs no arithmetic reduction at all.
hints:
- hidden: false
  text: Reflexivity needs identical endpoints, even when their value is unknown.
- hidden: true
  text: 'The law binds an erased natural number with `for -x: Nat`. Its body compares
    that value to itself.'
- hidden: true
  text: 'Keep the definition''s argument: `def same(x):`, then fill its body with
    the equality constructor.'
learning_goals:
- Reflexivity needs identical endpoints, even when their value is unknown.
- 'The law binds an erased natural number with `for -x: Nat`. Its body compares that
  value to itself.'
title: Equality of an arbitrary value
---
Reflexivity needs identical endpoints, even when their value is unknown.

The law binds an erased natural number with `for -x: Nat`. Its body compares that value to itself.

Keep the `law` declaration in the fixed statement and edit the matching `def` below it. **Check** (`C-c C-l`) finds named holes such as `?goal`. Select a hole and use **Goal** (`C-c C-,`). Enter a Bend expression in the expression box and press **Give** (`C-c C-SPC`), or edit the definition directly.

<!-- @conclusion -->
You have used this principle in Bend: Reflexivity needs identical endpoints, even when their value is unknown. Keep the technique from the worked example in mind when the surrounding expressions change.
