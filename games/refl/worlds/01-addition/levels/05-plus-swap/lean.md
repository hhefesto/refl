---
title: "add_left_comm"
learning_goals:
  - "Writing a `calc` block from scratch."
  - "Choosing intermediate terms so each step is one inventory lemma."
hints:
  - text: "`x` and `y` can't change places while `y` is tucked inside `y + z`. Use associativity to bring them next to each other first, then swap them, then put the parentheses back."
  - text: "The terms are `x + (y + z)`, then `(x + y) + z`, then `(y + x) + z`, then `y + (x + z)`."
  - text: "The three steps are `Eq.symm (add_assoc x y z)`, `congrArg (· + z) (add_comm x y)` and `add_assoc y x z`."
example_explanation: |-
  1. Compare the two sides: they differ only inside the left summand, `x + y` versus `y + x`.
  2. `add_comm x y` proves that inner equation, and `congrArg` with `(· + z)` carries it to the whole sum.
  For the exercise, first move the outer structure with `add_assoc` so the difference is again a single `add_comm` deep inside.
---
Same tools, no skeleton. The statement is `x + (y + z) = y + (x + z)`, and this time
you write the whole `calc` block yourself.

Start with this, which is the shape of any chain with one step:

```lean
  calc x + (y + z) = y + (x + z) := sorry
```

Now grow it. Add lines of the form `_ = next term := sorry`, each starting from the
term before. Every `sorry` is the equation for that one step, which is the whole point of
writing the terms down: you can see straight away whether a step is one lemma or still
too big. Mind the alignment, since each `_` line must be indented like the example.

So the real work is the plan. Which sums would you pass through, so that each move from
one to the next is exactly one lemma from your inventory?

<!-- @conclusion -->
Four rearrangement lemmas (`add_assoc`, `add_comm`, `add_right_comm`, `add_left_comm`) are
enough to move terms anywhere in a sum. Multiplication World uses them constantly.
