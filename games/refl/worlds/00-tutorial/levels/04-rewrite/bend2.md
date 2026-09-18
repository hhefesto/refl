---
example_explanation: |-
  1. View `5n` as `1n+4n`.
  2. The transport motive marks that `4n` endpoint with `_`, reducing the goal to `Refl.add(n, 1n) == 1n+n`.
  3. Both sides compute alike, so `{==}` closes it. Transfer the motive construction using the exercise's own constants.
hints:
- hidden: false
  text: An equality lets a proof move through a type that depends on its endpoint.
- hidden: true
  text: 'Bend transport is `%h : P`. The underscore in `P` marks the equation''s right
    endpoint; transport turns that occurrence back into the left endpoint.'
- hidden: true
  text: 'Begin `%h : {Refl.add(x, 2n) == 2n+_ : Nat}`, then inspect the equality that
    remains before filling its proof.'
learning_goals:
- An equality lets a proof move through a type that depends on its endpoint.
- 'Bend transport is `%h : P`. The underscore in `P` marks the equation''s right endpoint;
  transport turns that occurrence back into the left endpoint.'
title: Transport before computation
---
An equality lets a proof move through a type that depends on its endpoint.

Bend transport is `%h : P`. The underscore in `P` marks the equation's right endpoint; transport turns that occurrence back into the left endpoint.

Keep the `law` declaration in the fixed statement and edit the matching `def` below it. **Check** (`C-c C-l`) finds named holes such as `?goal`. Select a hole and use **Goal** (`C-c C-,`). Enter a Bend expression in the expression box and press **Give** (`C-c C-SPC`), or edit the definition directly.

<!-- @conclusion -->
You have used this principle in Bend: An equality lets a proof move through a type that depends on its endpoint. Keep the technique from the worked example in mind when the surrounding expressions change.
