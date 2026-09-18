---
learning_goals:
  - "`Eq.symm p` flips an equation; `Eq.trans p q` chains two."
  - "`rw [← p, q]` does both moves inside the goal."
hints:
  - text: "From `p : y = x` and `q : y = z` you need `x = z`: flip `p`, then chain with `q`."
  - text: "As a term: `exact Eq.trans (Eq.symm p) q`, or `exact p.symm.trans q`."
    hidden: true
  - text: "With rewriting: `rw [← p, q]` turns the goal `x = z` into `y = z`, then into `z = z`, which closes."
    hidden: true
example_explanation: |-
  1. Rewrite `a` to `b` using `p`.
  2. Rewrite `c` to `b` using `q`.
  3. The endpoints now agree. The exercise needs a reverse rewrite for its differently oriented first equation.
---
Equality is symmetric and transitive, and Lean names both: `Eq.symm` and
`Eq.trans` (also written `p.symm`, `p.trans q`). You can build the proof term
directly and hand it over with `exact`, or let `rw` walk the goal along the
equations: `←` rewrites right-to-left.

<!-- @conclusion -->
Two ways to the same proof: build the term, or rewrite the goal. Both `Eq.symm`
and `Eq.trans` are in your inventory now.
