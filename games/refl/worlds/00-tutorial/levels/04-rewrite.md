---
id: rewrite
index: 4
title: "rewrite"
learning_goals:
  - "`rewrite h` rewrites the goal with an equation before the `=`."
  - "Some moves are edits to the file, not expressions you can Give."
unlocks:
  syntax:
    - name: "rewrite"
      lean: "rw"
      bend2: "% transport"
      doc: "rewrite.md"
hints:
  - text: "The goal is `x + 2 ≡ 5` and you know `h : x ≡ 3`. If only `x` were `3`… `rewrite h` replaces every `x` in the goal by `3`. It goes on the **left** of `=`: `use-h x h rewrite h = ?`."
  - text: "Edit the line to `use-h x h rewrite h = ?`, Check again, and look at the goal: it is now `3 + 2 ≡ 5`, which is `refl`."
    hidden: true
---
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
