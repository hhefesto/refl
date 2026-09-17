---
id: rewrite-chain
index: 6
title: "Rewrite chains"
learning_goals:
  - "`rewrite p | q` applies several equations in order."
  - "Direction matters: `rewrite` uses the equation left to right; use `sym` to flip."
hints:
  - text: "`rewrite p | q = refl`."
    hidden: true
---
Several equations, separated by `|`. After both rewrites the goal is
`2 + 3 ≡ 5`.

<!-- @conclusion -->
`Block.lagda:112`: `rewrite splitAt-↑ˡ a i b | splitAt-↑ˡ a j b = refl`.
Same thing.
