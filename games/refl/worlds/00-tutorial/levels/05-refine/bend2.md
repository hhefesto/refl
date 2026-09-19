---
title: "Refine and Normalise"
learning_goals:
  - "`Refl.add` recurses on its second argument, so a numeral on the right computes all the way."
  - "`{==}` checks definitional equality: no lemma is needed when both sides compute to the same term."
hints:
  - text: "Press **Check** and read the goal as Bend normalises it."
  - text: "Both `Refl.add(Refl.add(x, 2n), 1n)` and `Refl.add(x, 3n)` unfold to `3n+x`: the numeral on the right drives the recursion."
    hidden: true
  - text: "`{==}` is the whole proof."
    hidden: true
example_explanation: |-
  1. Unfold each addition on the right numeral.
  2. Each side reduces to two successors of `n`.
  3. `{==}` checks the equality. The exercise uses different nested numerals with the same reduction rule.
---
No lemma here. `Refl.add` recurses on its second argument, so whenever that
argument is a numeral the sum unfolds into successors: `Refl.add(x, 3n)` is
`1n+Refl.add(x, 2n)`, and so on down to `3n+x`. The left side unfolds to the
same, and **Check** shows the goal already as `{3n+x == 3n+x : Nat}`.

<!-- @conclusion -->
First ask what computes; `{==}` decides definitional equality, and numerals on
the right of `Refl.add` always compute.
