---
id: refl
index: 1
title: "refl"
learning_goals:
  - "A hole `?` is a place where a proof is missing."
  - "`refl` proves `x ≡ x` — and `2 + 2 ≡ 4`, because the checker computes."
  - "The Check / Goal / Give loop."
unlocks:
  commands: [load, goal, give]
  lemmas:
    - name: "refl"
      agda: "refl"
      lean: "rfl"
      bend2: "{==}"
      doc: "refl.md"
hints:
  - text: "Press **Check** (or `C-c C-l`). The hole `?` becomes a numbered goal `?0`, and the right panel tells you what it wants: `2 + 2 ≡ 4`."
  - text: "Type `refl` in the expression box and press **Give** (`C-c C-SPC`). Agda replaces the hole with your expression if it has the right type."
  - text: "Why does `refl : 2 + 2 ≡ 4` type-check? Because `2 + 2` *computes* to `4` by the definition of `_+_`, and `refl` proves any `x ≡ x` when both sides compute to the same thing."
    hidden: true
---
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
