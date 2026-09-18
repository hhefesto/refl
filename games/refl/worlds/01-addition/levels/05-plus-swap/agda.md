---
example_explanation: |-
  1. Write the start, intermediate and final terms.
  2. Justify each edge by lifting a supplied equation.
  3. `begin` chains the edges. In the exercise choose intermediate sums so each edge is one available arithmetic lemma.
hints:
- hidden: false
  text: A large rearrangement can be decomposed into small, already proved equalities.
- hidden: true
  text: Expose `x + y` by reversing associativity, swap those terms, then reassociate.
- hidden: true
  text: Start a `begin` block with `x + (y + z)` and put `(x + y) + z` on its next
    line.
learning_goals:
- Writing a `begin` block from scratch.
- Choosing intermediate terms so each step is one inventory lemma.
title: +-swap
---
A large rearrangement can be decomposed into small, already proved equalities.

Same tools, no skeleton. Write the `begin … ∎` block yourself; check the
file after each step to see whether Agda agrees with your intermediate
terms (a wrong term is an error *at that step*, which is the point of
writing them down).


<!-- @conclusion -->

Three rearrangement lemmas (`+-assoc`, `+-comm`, `+-right-comm`, `+-swap`)
are enough to move terms anywhere in a sum. Multiplication World uses them
constantly.
