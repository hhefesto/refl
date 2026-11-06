---
title: "add_assoc"
learning_goals:
  - "A proof by induction where every step is `rw [add_succ]` and the hypothesis."
  - "Reading parentheses: `x + y + z` means `(x + y) + z`."
hints:
  - text: "On the left, the outer `+` looks at `z`. On the right, the outer `+` looks at `y + z`, and that looks at `z` too. `induction z with`."
  - text: "The `zero` case is `rfl`. In the `succ` case the goal is `x + y + z.succ = x + (y + z.succ)`, and three additions unfold. `rw [add_succ]` takes them one at a time."
  - text: "`| zero => rfl`, and `| succ z ih => rw [add_succ, add_succ, add_succ, ih]`."
example_explanation: |-
  1. Three variables, but `+` only computes on its second argument, and `z` is the innermost second argument on both sides: induct on `z`.
  2. `z = zero`: everything computes, so `rfl`.
  3. `z = succ z`: unfold with `add_succ` until `ih` applies. The exercise is the mirror image: same induction, same two cases.
---
Associativity: `(x + y) + z = x + (y + z)`. There are three variables now, so the
first real question is which one to induct on. The wrong choice leaves you stuck.

Here's how to decide without trying them all. Addition only looks at its second
argument, so take each side and ask what its outermost `+` is waiting for. On the
left, what's the second argument of the outer addition? On the right, it's a sum, so
what is *that* waiting for? You want the variable that lets **both** sides compute at
once.

A wrong guess costs nothing: press **Reset** and try another. Once you have the right
one, this is the easiest induction so far.

A note on reading goals: Lean prints `(x + y) + z` as `x + y + z`, without the
parentheses. Same term.

<!-- @conclusion -->
`+` associates to the left, so `x + y + z` parses as `(x + y) + z`, which is why Lean can
leave the parentheses out.
