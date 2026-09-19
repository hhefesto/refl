---
title: "Refine and Normalise"
learning_goals:
  - "**Refine** (`C-c C-r`) puts an expression in the hole and opens new holes for its missing arguments."
  - "**Normalise** (`C-c C-n`) shows what an expression computes to."
  - "`_+_` computes on its second argument, so `(x + 2) + 1` and `x + 3` are the same by definition."
hints:
  - text: "Before proving anything, type `(x + 2) + 1` in the box and press **Normalise**. Then normalise `x + 3`. Same answer?"
  - text: "If two sides normalise to the same thing, `refl` proves it. Try **Refine** with `refl` this time instead of Give — for `refl` they do the same; Refine matters when the expression has arguments you leave out."
    hidden: true
example_explanation: |-
  1. Expand both additions on their right arguments.
  2. Each side becomes `suc (suc n)`.
  3. Close with `refl`. The same normalization test applies to the exercise's longer expression.
---
Two new commands.

**Normalise** evaluates an expression as far as the definitions allow. It is
how you find out whether `refl` will work: if both sides of `≡` normalise to
the same term, it will.

**Refine** is Give's more forgiving sibling. Refine with `f` when the goal is
`f ? ?`: Agda inserts `f` and creates holes for the arguments it could not
figure out. Refine with a constructor to build a value piece by piece.

<!-- @conclusion -->
You have just seen why the definition of `_+_` matters: everything computed
because the recursion is on the second argument and the numerals were on the
right. When they are on the left, you need induction. Next level.
