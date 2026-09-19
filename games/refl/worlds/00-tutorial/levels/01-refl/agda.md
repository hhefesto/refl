---
example_explanation: |-
  This example asks about `3 + 1`, a different sum. Expand `1` first:

  ```text
  3 + 1
  → 3 + suc zero
  → suc (3 + zero)
  → suc 3
  → suc (suc (suc (suc zero)))
  ```

  The middle steps use the successor and zero rules. The last expands `3`
  to three successors of `zero`. Independently, the right-hand `4` expands
  to `suc (suc (suc (suc zero)))`. The local name `same` has this normalized
  equality as its type; `refl` supplies its proof, and `in same` returns it.
  Replacing the entire `let … in …` expression by `refl` gives the short
  proof: Agda performs the same computation automatically.
---
