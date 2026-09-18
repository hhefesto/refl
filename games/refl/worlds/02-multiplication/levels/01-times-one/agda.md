---
example_explanation: |-
  1. Normalize the outer additions into successors.
  2. `zero-+ n` handles the inner expression that is stuck.
  3. Lift that equation through `suc`. In the exercise normalize first, then identify the existing lemma that matches the remaining goal.
hints:
- hidden: false
  text: Unfolding a definition can reduce a new theorem to an older one.
- hidden: true
  text: The numeral one is a successor of zero. Unfold multiplication to see an addition
    with zero on the left.
- hidden: true
  text: Keep `*-one x = …` and find the inventory lemma about that addition.
learning_goals:
- 'Unfold a definition by hand: `x * 1` is `x * zero + x`, which is `zero + x`.'
- Reuse `zero-+`.
title: '*-one'
---
Unfolding a definition can reduce a new theorem to an older one.

`1` is `suc zero`, so `x * 1 = x * zero + x = zero + x`. One inventory
lemma finishes it. No induction.


<!-- @conclusion -->

`x * zero ≡ zero` is `refl` and never needs a lemma, just like `x + zero`.
