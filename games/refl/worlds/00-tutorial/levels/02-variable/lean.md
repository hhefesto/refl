---
title: "A variable in the way"
learning_goals:
  - "A universally quantified statement becomes a theorem with named arguments."
  - "`rfl` does not care whether the sides are numerals or variables, only that they are the same."
hints:
  - text: "`x` is a hypothesis now: the goal is `x = x` for an arbitrary `x`."
  - text: "Nothing computes here, but nothing needs to: both sides are literally the same term, and `rfl` accepts that."
    hidden: true
  - text: "The whole proof is `  rfl`."
    hidden: true
example_explanation: |-
  1. Introduce an arbitrary `n` in the declaration.
  2. Addition on the right zero computes to `n`.
  3. Use `rfl`. The exercise is already reflexive without even unfolding addition.
---
The theorem takes an argument `(x : MyNat)`; inside the proof it is a
hypothesis, listed above the `⊢` line when you ask for the **Goal**. There is
no case to consider and nothing to compute: `x = x` holds by reflexivity for
any `x`.

<!-- @conclusion -->
Variables are hypotheses; `rfl` needs the two sides to be the *same term*,
computed or not.
