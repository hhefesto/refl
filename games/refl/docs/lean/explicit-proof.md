`by` starts an indented tactic block. `change P` asks Lean to display goal
`P`; Lean checks that it computes to the same proposition as the old goal.
It cannot replace the goal with an unrelated claim.

```lean
  change (zero : MyNat) = zero
  rfl
```

This block proves equality of zero with itself. The annotation
`(zero : MyNat)` selects our type; `rfl` supplies the proof after `change`.
