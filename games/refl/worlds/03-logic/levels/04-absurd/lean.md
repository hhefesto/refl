---
learning_goals:
  - "`False` has no constructors, so `cases` on it leaves nothing to do."
  - "`True` has exactly one proof, `True.intro`."
  - "`constructor` splits a pair into two goals, and `·` focuses on one."
hints:
  - text: "`constructor` gives you two goals, one for each side. Use one `·` line for each."
  - text: "The first goal is `A`, with `h : False` above the line. `cases h` closes it. The second is `True`."
  - text: "`constructor`, then `· cases h`, then `· exact True.intro`."
example_explanation: |-
  1. `cases` the disjunction.
  2. Its left payload is impossible, so `cases h` finishes with nothing left to do.
  3. The right payload is already a proof of `True`. These two cases show the separate jobs in the exercise.
---
Two opposite propositions, each with an unusual number of constructors:

```lean
inductive True : Prop where
  | intro : True

inductive False : Prop
```

`True` has one proof, `True.intro`, and that proof says nothing. `False` has **no** constructors at all, so there's no way to
build a proof of it.

The statement says that from `False` you can conclude anything: here, `A ∧ True`, for *any* `A`. How can you prove `A`, when
nothing is known about it? You never have to. Think about what `cases` does: it gives you one case per constructor. So what
does it do for a type with no constructors?

Since the goal is a pair, split it first. The tactic `constructor` turns the goal `A ∧ True` into two goals, and `·` (type `\cdot`)
focuses on one at a time:

```lean
  constructor
  · sorry
  · sorry
```

<!-- @conclusion -->
`False.elim` in Lean's library is this principle. You'll use it whenever a hypothesis is impossible, usually through
`absurd`.
