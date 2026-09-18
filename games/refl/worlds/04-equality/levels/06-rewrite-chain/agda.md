---
example_explanation: |-
  1. Rewrite the first variable with `p`.
  2. Rewrite the second with `q`.
  3. The remaining numeric equality computes. Transfer the order of substitutions, using the exercise's hypotheses.
hints:
- hidden: false
  text: Several substitutions can expose a fully computable equality.
- hidden: true
  text: Each hypothesis fixes one variable. Apply them left to right before trying
    reflexivity.
- hidden: true
  text: Use `rewrite p | q = …` after the existing arguments.
learning_goals:
- '`rewrite p | q` applies several equations in order.'
- 'Direction matters: `rewrite` uses the equation left to right; use `sym` to flip.'
title: Rewrite chains
---
Several substitutions can expose a fully computable equality.

Several equations, separated by `|`. After both rewrites the goal is
`2 + 3 ≡ 5`.


<!-- @conclusion -->

`Block.lagda:112`: `rewrite splitAt-↑ˡ a i b | splitAt-↑ˡ a j b = refl`.
Same thing.
