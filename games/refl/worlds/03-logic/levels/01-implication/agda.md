---
title: "Implication is a function"
learning_goals:
  - "A proof of `A → B` is a function."
  - "Introduce hypotheses as arguments, or with `λ`."
hints:
  - text: "Check, ask for the goal: `A → (A → B) → B`. Refine with an empty box: Agda introduces the arguments for you (`modus-ponens a f = ?`)."
  - text: "Then `f a`. Or write the whole thing as `λ a f → f a`."
    hidden: true
example_explanation: |-
  1. Introduce the functions and the value.
  2. `f a` has type `B`.
  3. Apply `g` to obtain `C`. In the exercise follow the types to choose which function consumes the available value.
---
Modus ponens: from `A` and `A → B` conclude `B`. Two ways to write the
proof: name the arguments on the left of `=`, or give a lambda
`λ a f → f a`. Try **Refine** with an empty expression box to make Agda
introduce the arguments.

<!-- @conclusion -->
`A`, `B` are arbitrary types (`Set`). Nothing about them is known, so the
only possible proof is the one that uses the hypotheses. That is the sense
in which this is *logic*.
