---
example_explanation: |-
  1. The anonymous function takes an equality.
  2. Matching `refl` unifies the endpoints.
  3. Their successors now agree by reflexivity. In the exercise the target reverses the endpoints instead.
hints:
- hidden: false
  text: An anonymous function can eliminate equality by matching its constructor.
- hidden: true
  text: The named symmetry lemma is forbidden here. Match the evidence, so both endpoints
    become the same.
- hidden: true
  text: Use `λ { refl → … }`.
learning_goals:
- '`λ { pat → e; … }` is an anonymous function defined by cases.'
- '`λ ()` is the anonymous absurd function.'
title: Pattern-matching lambdas
---
An anonymous function can eliminate equality by matching its constructor.

Prove `sym` again, without arguments on the left of `=` and without using
`sym`: give a lambda that matches its argument.


<!-- @conclusion -->

`Inverses.lagda:78-87` builds isomorphisms with `mk↔′ … (λ { refl → refl })`,
and `Examples.lagda:119` in Spectra2 uses `(λ { zero zero → refl })`.
