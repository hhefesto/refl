---
title: "Pattern-matching functions"
learning_goals:
  - "`fun | pat => e | …` is an anonymous function defined by cases."
  - "`nofun` is the anonymous function with no cases."
hints:
  - text: "Write `exact fun | rfl => sorry`, and press **Goal** on the `sorry`. It says `x = x`."
  - text: "Matching against `rfl` has made `y` into `x`, so the goal is a thing equal to itself. `exact fun | rfl => rfl`."
example_explanation: |-
  1. The anonymous function takes an equality.
  2. Matching `rfl` unifies the two sides.
  3. Their successors now agree by `rfl`. In the exercise the target reverses the sides instead.
---
Sometimes you want a small function, defined by cases, in the middle of an expression. You saw one in `map_succ`, in Logic World:

```lean
isFalse (fun | rfl => np rfl)
```

`fun | pattern => body` is an anonymous function defined by cases, with a new `|` for each one. It can do what any `match` can do, including matching an
equation against `rfl`.

This level proves `Eq.symm` this way, under the name `sym'`. The real one is forbidden here. The goal is `x = y → y = x`, a function type, so you can hand it
a function directly, without `intro`.

This is the same move as this world's first level, in a different spelling.

<!-- @conclusion -->
You'll see these all over real code. They're the usual way to pass a small proof by cases to something else, without naming it. And `nofun` from Logic World is the same
idea with no cases at all.
