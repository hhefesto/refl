---
example_explanation: |-
  1. Unfold addition on the right numeral, obtaining `suc 3`.
  2. Both sides are `4`, so `refl` closes the equality.
  3. In the exercise, compute its own numerals before choosing a proof.
hints:
- hidden: false
  text: Equality needs no extra evidence when both sides compute to the same value.
- hidden: true
  text: Check the file and inspect the numeric equality with Goal. Addition reduces
    on its second argument.
- hidden: true
  text: 'Keep the declaration name and replace only the hole: `two-plus-two = …`.'
learning_goals:
- A hole `?` is a place where a proof is missing.
- '`refl` proves `x ≡ x` — and `2 + 2 ≡ 4`, because the checker computes.'
- The Check / Goal / Give loop.
title: refl
---
Equality needs no extra evidence when both sides compute to the same value.

Your first proof. The statement is fixed (you cannot edit the grey box); your
job is the definition below it, which currently ends in a **hole** `?`.

The loop you will repeat a thousand times:

1. **Check** the file (`C-c C-l`). Agda reads it and turns every `?` into a
   numbered goal.
2. Select a goal and ask for its **Goal** (`C-c C-,`) to see what type it wants
   and what is in scope.
3. Write an expression of that type in the box and **Give** it
   (`C-c C-SPC`). If it type-checks, it replaces the hole.

When no holes and no errors remain, the level is solved.


<!-- @conclusion -->

That is the whole game: `refl` says "both sides are the same", and the type
checker *computes* to find out. Everything else is learning to bring the two
sides of an equation to the point where `refl` works.

Next: the same thing with a variable in the way.
