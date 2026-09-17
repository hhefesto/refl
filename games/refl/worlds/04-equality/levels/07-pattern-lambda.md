---
id: pattern-lambda
index: 7
title: "Pattern-matching lambdas"
learning_goals:
  - "`λ { pat → e; … }` is an anonymous function defined by cases."
  - "`λ ()` is the anonymous absurd function."
unlocks:
  syntax:
    - name: "λ { … }"
      doc: "pattern-lambda.md"
forbids: ["sym"]
hints:
  - text: "Give `λ { refl → refl }`: the argument is matched against `refl`, after which `y ≡ x` is `x ≡ x`."
    hidden: true
---
Prove `sym` again, without arguments on the left of `=` and without using
`sym`: give a lambda that matches its argument.

<!-- @conclusion -->
`Inverses.lagda:78-87` builds isomorphisms with `mk↔′ … (λ { refl → refl })`,
and `Examples.lagda:119` in Spectra2 uses `(λ { zero zero → refl })`.
