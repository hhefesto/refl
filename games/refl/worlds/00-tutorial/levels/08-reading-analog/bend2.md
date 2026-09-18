---
example_explanation: |-
  1. `shifted(k)` returns a lambda.
  2. The explicit version takes the lambda argument as its second parameter.
  3. Both compute to the same addition, proved by `{==}`. The exercise wraps this time shift in two further function calls.
hints:
- hidden: false
  text: Returning a function and accepting its argument explicitly describe the same
    computation.
- hidden: true
  text: 'The first hole defines the version with explicit `t`. Preserve the order:
    shift time, sample `xs`, then apply `h`.'
- hidden: true
  text: Start the first body with `h(xs(…))`. After defining it, compare the two sides
    of the equality by computation.
learning_goals:
- Returning a function and accepting its argument explicitly describe the same computation.
- 'The first hole defines the version with explicit `t`. Preserve the order: shift
  time, sample `xs`, then apply `h`.'
title: Reading a function-valued definition
---
Returning a function and accepting its argument explicitly describe the same computation.

The first hole defines the version with explicit `t`. Preserve the order: shift time, sample `xs`, then apply `h`.

Keep the `law` declaration in the fixed statement and edit the matching `def` below it. **Check** (`C-c C-l`) finds named holes such as `?goal`. Select a hole and use **Goal** (`C-c C-,`). Enter a Bend expression in the expression box and press **Give** (`C-c C-SPC`), or edit the definition directly.

<!-- @conclusion -->
You have used this principle in Bend: Returning a function and accepting its argument explicitly describe the same computation. Keep the technique from the worked example in mind when the surrounding expressions change.
