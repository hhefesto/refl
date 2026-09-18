---
example_explanation: |-
  1. The first proof already runs from `a` to `b`.
  2. Reverse `q` to go from `b` to `c`.
  3. Compose with `Equal.trans`. The exercise reverses the first edge instead.
hints:
- hidden: false
  text: Equalities compose through a common intermediate value.
- hidden: true
  text: Read the endpoints of `p` and `q`. `Equal.sym` reverses one edge; `Equal.trans`
    combines two edges with matching endpoints.
- hidden: true
  text: Start `Equal.trans(Nat, x, y, z, …, q)` and supply an equality from `x` to
    `y`.
learning_goals:
- Equalities compose through a common intermediate value.
- Read the endpoints of `p` and `q`. `Equal.sym` reverses one edge; `Equal.trans`
  combines two edges with matching endpoints.
title: Orienting and chaining equations
---
Equalities compose through a common intermediate value.

Read the endpoints of `p` and `q`. `Equal.sym` reverses one edge; `Equal.trans` combines two edges with matching endpoints.

Keep the `law` declaration in the fixed statement and edit the matching `def` below it. **Check** (`C-c C-l`) finds named holes such as `?goal`. Select a hole and use **Goal** (`C-c C-,`). Enter a Bend expression in the expression box and press **Give** (`C-c C-SPC`), or edit the definition directly.

<!-- @conclusion -->
You have used this principle in Bend: Equalities compose through a common intermediate value. Keep the technique from the worked example in mind when the surrounding expressions change.
