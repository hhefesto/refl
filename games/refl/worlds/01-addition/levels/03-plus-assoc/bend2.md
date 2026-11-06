---
title: "add_assoc"
learning_goals:
  - "A proof by induction where every case is `{==}` or `Equal.cong`."
  - "Choosing which variable to induct on."
hints:
  - text: "On the left, the outer `add` looks at `z`. On the right, the outer `add` looks at `Refl.add(y, z)`, and that looks at `z` too. `match z:`."
  - text: "The `0n` case is `{==}`. The `1n+p` case's goal is `{1n+Refl.add(Refl.add(x, y), p) == 1n+Refl.add(x, Refl.add(y, p)) : Nat}`: this same statement for the smaller `p`, under a `1n+`."
  - text: "`Equal.cong(Nat, Nat, n => 1n+n, Refl.add(Refl.add(x, y), p), Refl.add(x, Refl.add(y, p)), add_assoc(x, y, p))`."
example_explanation: |-
  1. Three variables, but `add` only computes on its second argument, and `z` is the innermost second argument on both sides: match on `z`.
  2. `z = 0n`: everything computes, so `{==}`.
  3. `z = 1n+p`: both sides become `1n+…`, so `Equal.cong` of the recursive call. The exercise is the mirror image: same match, same two cases.
---
Associativity: `Refl.add(Refl.add(x, y), z) == Refl.add(x, Refl.add(y, z))`. There are three variables now, so the first real question is which one to match on. The wrong choice leaves you stuck.

Here's how to decide without trying them all. Addition only looks at its second argument, so take each side and ask what its outermost `add` is waiting for. On the left, what's the second argument of the outer call? On the right, it's another `add`, so what is *that* waiting for? You want the variable that lets **both** sides compute at once.

Notice the statement: `x` and `y` are marked `+`, because the recursive call uses them again. `z` isn't, because the match consumes it.

A wrong guess costs nothing: press **Reset** and try another. Once you have the right one, this is the easiest induction so far.

<!-- @conclusion -->
Choose the right variable and the proof writes itself. It's the same idea in every prover: the variable you match on should be the one the definition is waiting for.
