---
title: "Reading: analog₁ (Timely Computation)"
learning_goals:
  - "A `def` returning a function (`t => …`) and a `law` with one more argument describe the same thing."
  - "`{==}` sees through definitions: both sides unfold to `h(xs(Refl.add(t, d)))`."
hints:
  - text: "Two holes: first give `analog1_` a body, then prove the equation."
  - text: "`analog1_(d, h, xs, t)` should compute what `analog1(d, h, xs)(t)` computes: `h(xs(Refl.add(t, d)))`."
    hidden: true
  - text: "With that body in place, the two sides of `analog_same` unfold to the same term, and `{==}` proves it."
    hidden: true
example_explanation: |-
  1. `shifted(k)` returns a lambda.
  2. The explicit version takes the lambda argument as its second parameter.
  3. Both compute to the same addition, proved by `{==}`. The exercise wraps this time shift in two further function calls.
---
The reading level, in Bend. `analog1` returns a function `t => …`;
`analog1_` is declared by a `law` with one more argument and you write its
`def`. Once its body is the same expression, applying `analog1(d, h, xs)` to
`t` and calling `analog1_(d, h, xs, t)` unfold to the same term, and the
equation is `{==}`. Function types are written `Nat -> Nat`.

<!-- @conclusion -->
Definitions unfold; `{==}` checks the result. That is the Tutorial in Bend:
`{==}`, `%` rewriting, `Equal.cong/sym/trans`, `match`, and reading.
