---
title: "add_left_comm"
learning_goals:
  - "Writing an `Equal.trans` chain from scratch."
  - "Choosing intermediate terms so each step is one inventory lemma."
hints:
  - text: "`x` and `y` can't change places while `y` is tucked inside `Refl.add(y, z)`. Use associativity to bring them next to each other first, then swap them, then put the parentheses back."
  - text: "The terms are `Refl.add(x, Refl.add(y, z))`, then `Refl.add(Refl.add(x, y), z)`, then `Refl.add(Refl.add(y, x), z)`, then `Refl.add(y, Refl.add(x, z))`."
  - text: "The three reasons are `Equal.sym(Nat, Refl.add(Refl.add(x, y), z), Refl.add(x, Refl.add(y, z)), Addition.add_assoc(x, y, z))`, `Equal.cong(Nat, Nat, n => Refl.add(n, z), Refl.add(x, y), Refl.add(y, x), Addition.add_comm(x, y))` and `Addition.add_assoc(y, x, z)`."
example_explanation: |-
  1. Compare the two sides: they differ only inside the left summand, `Refl.add(x, y)` versus `Refl.add(y, x)`.
  2. `add_comm(x, y)` proves that inner equation, and `Equal.cong` with `n => Refl.add(n, z)` carries it to the whole sum.
  For the exercise, first move the outer structure with `add_assoc` so the difference is again a single `add_comm` deep inside.
---
Same tools, no skeleton. The statement is `Refl.add(x, Refl.add(y, z)) == Refl.add(y, Refl.add(x, z))`, and this time you write the whole chain yourself.

Any chain is `Equal.trans(Nat, a, b, c, ?first, ?second)`, and `?second` can be another `Equal.trans` if you need more steps. Line breaks inside the parentheses are fine.

So the real work is the plan. Which sums would you pass through, so that each move from one to the next is exactly one lemma from your inventory? Write them on paper first. With the terms in place, put a hole in each reason and **Goal** will show you the one equation for that step, so you can see straight away whether a step is one lemma or still too big.

<!-- @conclusion -->
Four rearrangement lemmas (`add_assoc`, `add_comm`, `add_right_comm`, `add_left_comm`) are enough to move terms anywhere in a sum. Multiplication World uses them constantly.
