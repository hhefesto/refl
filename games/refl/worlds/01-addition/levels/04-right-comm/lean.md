---
title: "add_right_comm"
learning_goals:
  - "A `calc` chain writes down the terms a proof passes through."
  - "Plan the intermediate terms first, then fill in the justifications."
  - "`(x + ·)` is `fun y => x + y`."
hints:
  - text: "Put the cursor on the first `sorry` and press **Goal**: `x + y + z = x + (y + z)`. That's a lemma you have, word for word."
  - text: "The second step is `x + (y + z) = x + (z + y)`. The `x +` stays put and only `y + z` changes: `add_comm y z`, under `congrArg (x + ·)`. The third is the first one's shape, backwards."
  - text: "The three steps are `add_assoc x y z`, `congrArg (x + ·) (add_comm y z)` and `Eq.symm (add_assoc x z y)`."
example_explanation: |-
  1. Write the start, intermediate and final terms.
  2. Justify each step by lifting a supplied equation with `congrArg`.
  3. `calc` chains the steps. In the exercise choose intermediate sums so each step is one available lemma.
---
`calc` writes a proof as a chain of equations, naming the terms it passes through:

```lean
  calc a = b := p
    _ = c := q
```

Here `p : a = b` and `q : b = c`, and `_` stands for the right side of the line above.
In the Tutorial you walked a goal down with `conv` and `change`, one side at a time. A
chain goes the whole way, and each step carries the lemma that justifies it.

The statement moves `z` past `y`: `(x + y) + z = (x + z) + y`. There's no induction here.
You already know addition is associative and commutative, so it's only a matter of
rearranging, and the template gives you the plan. **Goal** on a `sorry` tells you exactly
which equation that step needs.

One step changes only part of a sum. For that, Lean has a neat notation: `(x + ·)` means
`fun y => x + y`, the function that adds `x` on the left. Type `·` as `\cdot`. So
`congrArg (x + ·) e` applies `e` underneath the `x +`.

<!-- @conclusion -->
A `rw` chain is shorter, but a `calc` block says what's going on at each step, which is
what makes a long proof readable afterwards.
