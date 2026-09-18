---
example_explanation: |-
  1. Introduce `n` and its equation `h`.
  2. Rewrite `n` to `4`.
  3. The remaining arithmetic computes. In the exercise use its hypothesis and its own numerals.
hints:
- hidden: false
  text: An equality hypothesis lets you replace one value by another before computing.
- hidden: true
  text: The hypothesis fixes `x` to a numeral. Rewriting it exposes the arithmetic.
- hidden: true
  text: Start `use-h x h rewrite h = …`, then inspect what still needs proving.
learning_goals:
- '`rewrite h` rewrites the goal with an equation before the `=`.'
- Some moves are edits to the file, not expressions you can Give.
title: rewrite
---
An equality hypothesis lets you replace one value by another before computing.

Not everything is an expression you can *Give* into a hole. `rewrite` is a
keyword that goes on the left-hand side of a clause, before the `=`:

```agda
name args rewrite equation = rhs
```

It rewrites the goal (and the context) using the equation, left to right, and
then you prove what is left. Here `h : x ≡ 3` turns the goal `x + 2 ≡ 5` into
`3 + 2 ≡ 5`.

This level is about the editor: type the change yourself, then Check.


<!-- @conclusion -->

`rewrite` is Agda's `rw`. Under the hood it is a `with` abstraction over the
equation (World 4 opens that box). For now: when the goal mentions something
you have an equation for, rewrite.
