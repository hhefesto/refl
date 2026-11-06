---
learning_goals:
  - "Rewrites can follow each other, one to a line."
  - "Direction matters: `_` marks the right side of the equation, and `Equal.sym` flips it."
hints:
  - text: "The goal mentions `x` and `y`, and you have an equation for each. But `p : {x == 2n : Nat}` has `x` on the left, and `_` marks the right. So flip it: `%Equal.sym(Nat, x, 2n, p) : {Refl.add(_, y) == 5n : Nat}`."
  - text: "Then `%Equal.sym(Nat, y, 3n, q) : {Refl.add(2n, _) == 5n : Nat}`. Each rewrite sees the goal as the last one left it. **Goal** now says `{5n == 5n : Nat}`."
  - text: "Those two lines, then `{==}`."
example_explanation: |-
  1. Rewrite the first variable with `p` flipped.
  2. Rewrite the second with `q` flipped.
  3. The remaining numeric equality computes. Use the same order of substitutions with the exercise's hypotheses.
---
You've used `%e : P` with one equation. Several work the same way, one line after another, each working on the goal the last one left:

```
%e1 : P1
%e2 : P2
{==}
```

Here `p : {x == 2n : Nat}` and `q : {y == 3n : Nat}`, and the goal is `{Refl.add(x, y) == 5n : Nat}`.

The direction is the part to get right. With `e : {a == b : T}`, `_` marks `b`, and it's replaced by `a`. So to replace an `x` by a `2n`, you need an equation with `x` on the right. `p` has it on the left, so flip it with `Equal.sym(Nat, x, 2n, p)`.

Then `P` is the goal, with `_` where the `x` is. Press **Goal** after each line to see what's left.

<!-- @conclusion -->
Real proofs are full of these chains, sometimes several lemmas long. Read one the way the checker does, one equation at a time, and watch which side each one marks.
