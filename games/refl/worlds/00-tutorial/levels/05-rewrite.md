---
id: rewrite
index: 5
title: "rewrite"
learning_goals:
  - "`rewrite h` rewrites the goal with an equation before the `=`."
  - "Some moves are edits to the file, not expressions you can Give."
unlocks:
  syntax:
    - name: "rewrite"
      lean: "rw"
      bend2: "%h : P"
      doc: "rewrite.md"
hints:
  - text: "The context has `h : x ≡ 3` and the goal mentions `x`. Edit the line to `use-h x h rewrite h = ?` and press **Check**."
  - text: "Select the new hole and press **Goal**. It says `5 ≡ 5`, and you know what proves that: `refl`."
---
Not everything is an expression you can *Give* into a hole. `rewrite` is a
keyword that goes on the left-hand side of a clause, before the `=`:

```agda
name args rewrite equation = rhs
```

It replaces the equation's left side with its right side everywhere in the goal,
and then you prove what is left.

Press **Check**, select the hole and press **Goal**. You will see
`suc (suc x) ≡ 5`: Agda has computed `x + 2` as far as it can, and it is stuck on
the variable `x`. No amount of computing will help, because `x` could be anything
as far as `+` can tell. But you also have `h : x ≡ 3` in the context, which says
what `x` is.

So this level is about the editor: there is nothing to give yet. Type the change
into the clause yourself, put a new `?` after the `=`, then **Check** again and
read the new goal.

<!-- @conclusion -->
`rewrite` is the move Lean calls `rw`. Under the hood it is a `with` abstraction
over the equation, and Equality World opens that box. For now: when the goal
mentions something you have an equation for, rewrite.
