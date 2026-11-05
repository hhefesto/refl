---
id: refine
index: 6
title: "Refine and Normalise"
learning_goals:
  - "**Refine** (`C-c C-r`) puts an expression in the hole and opens new holes for its missing arguments."
  - "**Normalise** (`C-c C-n`) shows what an expression computes to."
  - "`_+_` computes on its second argument, so `(x + 2) + 1` and `x + 3` are the same by definition."
unlocks:
  commands: [refine, normalise, infer]
hints:
  - text: "Select the hole, type `(x + 2) + 1` in the box and press **Normalise**. Then do the same with `x + 3`. Do you get the same answer?"
  - text: "Both give `suc (suc (suc x))`. If the two sides normalise to the same term, `refl` proves it. Try **Refine** with `refl` this time instead of Give; for `refl` they do the same, because it has no arguments to leave out."
---
Two new commands.

**Normalise** (`C-c C-n`) evaluates an expression as far as the definitions
allow. Select the hole, type an expression in the box and press it. This is how
you find out whether the checker will accept a proof by computation before you
try one: if both sides of `≡` normalise to the same term, they are definitionally
equal.

**Refine** (`C-c C-r`) is Give's more forgiving sibling. Give demands a finished
term. Refine with a function `f` writes `f ? ?`, with a new hole for each argument
it could not work out. So you can build a proof from the outside in, one piece at
a time.

The statement here is `(x + 2) + 1 ≡ x + 3`. There is a variable in it, but notice
where: every addition has a numeral on the right, and numerals are what addition
looks at. Use **Normalise** on each side to see how far they get.

<!-- @conclusion -->
You have just seen why the definition of `_+_` matters: everything computed
because the recursion is on the second argument and the numerals were on the
right. When they are on the left, you need induction. That is the next level.
