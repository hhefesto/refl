---
learning_goals:
  - "`Empty` has no constructors, so a `match` on it has no cases."
  - "`Unit` has exactly one proof, `Unit{}`."
hints:
  - text: "For `ex_falso`, write `match h:` and nothing under it. A `match` has one case for each constructor, and `Empty` has none."
  - text: "For `trivial`, `Unit` has one constructor: `Unit{}`."
example_explanation: |-
  1. Match on the disjunction.
  2. Its left payload is impossible, so a `match` with no cases closes it.
  3. The right payload is already a proof of `Unit`. These two cases show the separate jobs in the exercise.
---
Two opposite types, each with an unusual number of constructors:

```
type Empty is Data:

type Unit is Data:
  Unit{}
```

`Unit` is truth: it has one proof, `Unit{}`, and that proof says nothing. `Empty` is falsity: it has **no** constructors at all, so there's no way to build a proof of it.

There are two lemmas in this level. `trivial` is as easy as it looks. The interesting one is `ex_falso`: from a proof of `Empty`, conclude anything, for *any* type `A`.

How can a function return a value of a type it knows nothing about? It never has to. Think about what `match` does: it asks for one case per constructor. So what does it ask for on a type with no constructors?

<!-- @conclusion -->
`Empty.absurd(A, e)` in Base is exactly `ex_falso`. You'll use it whenever a hypothesis is impossible.
