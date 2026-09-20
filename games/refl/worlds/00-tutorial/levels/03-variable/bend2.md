---
learning_goals:
  - "`for -x: Nat` binds an argument that is erased: it appears only in types."
  - "`{==}` needs the two sides to be the same term, computed or not."
hints:
  - text: "The goal is `{x == x : Nat}` for an arbitrary `x` in the context."
  - text: "Nothing computes, and nothing has to: both sides are the same term, and `{==}` accepts that."
    hidden: true
  - text: "**Give** `{==}`."
    hidden: true
example_explanation: |-
  1. Bind the arbitrary number in the law.
  2. Addition on the right zero computes.
  3. `{==}` proves the resulting reflexive equality. The exercise needs no arithmetic reduction at all.
---
The `law` quantifies with `for -x: Nat`: the `-` marks `x` as *erased*, it
may appear in types but not in computations, which is right for a variable
that only shows up in an equation. In the `def`, `x` is an ordinary argument
name. The goal is `{x == x : Nat}` and `{==}` closes it.

<!-- @conclusion -->
Erased arguments (`-x`) are Bend's way of saying "this is only for the
type". `{==}` cares about sameness, not about numerals.
