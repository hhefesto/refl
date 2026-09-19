---
title: "Pattern-matching lambdas"
learning_goals:
  - "`λ { pat → e; … }` is an anonymous function defined by cases."
  - "`λ ()` is the anonymous absurd function."
hints:
  - text: "Give `λ { refl → refl }`: the argument is matched against `refl`, after which `y ≡ x` is `x ≡ x`."
    hidden: true
example_explanation: |-
  1. The anonymous function takes an equality.
  2. Matching `refl` unifies the endpoints.
  3. Their successors now agree by reflexivity. In the exercise the target reverses the endpoints instead.
---
Prove `sym` again, without arguments on the left of `=` and without using
`sym`: give a lambda that matches its argument.

<!-- @conclusion -->
`Inverses.lagda:78-87` builds isomorphisms with `mk↔′ … (λ { refl → refl })`,
and `Examples.lagda:119` in Spectra2 uses `(λ { zero zero → refl })`.
