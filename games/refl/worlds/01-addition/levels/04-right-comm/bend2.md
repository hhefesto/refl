---
title: "add_right_comm"
learning_goals:
  - "A chain of `Equal.trans` can name every term it passes through."
  - "Plan the intermediate terms first, then fill in the justifications."
  - "`n => Refl.add(x, n)` is what you pass to `Equal.cong` to change part of a sum."
hints:
  - text: "Select `?first` and press **Goal**: `{Refl.add(Refl.add(x, y), z) == Refl.add(x, Refl.add(y, z)) : Nat}`. That's a lemma you have, word for word."
  - text: "`?second` is `{Refl.add(x, Refl.add(y, z)) == Refl.add(x, Refl.add(z, y)) : Nat}`. The outer `Refl.add(x, …)` stays put and only the inside changes. `?third` is the first one's shape, backwards."
  - text: "`?first` is `Addition.add_assoc(x, y, z)`. `?second` is `Equal.cong(Nat, Nat, n => Refl.add(x, n), Refl.add(y, z), Refl.add(z, y), Addition.add_comm(y, z))`. `?third` is `Equal.sym(Nat, Refl.add(Refl.add(x, z), y), Refl.add(x, Refl.add(z, y)), Addition.add_assoc(x, z, y))`."
example_explanation: |-
  1. Write the start, intermediate and final terms as the arguments of `Equal.trans`.
  2. Justify each step by lifting a supplied equation with `Equal.cong`.
  3. In the exercise, choose intermediate sums so each step is one available lemma.
---
The statement moves `z` past `y`: `Refl.add(Refl.add(x, y), z) == Refl.add(Refl.add(x, z), y)`. There's no induction here. You already know addition is associative and commutative, so it's only a matter of rearranging.

When a proof has several steps, plan the terms it passes through first:

1. `Refl.add(Refl.add(x, y), z)`
2. `Refl.add(x, Refl.add(y, z))`
3. `Refl.add(x, Refl.add(z, y))`
4. `Refl.add(Refl.add(x, z), y)`

Then each step is one equation. The template is that plan, as two nested `Equal.trans` with their endpoints spelled out and three holes for the reasons. **Goal** on a hole shows exactly which equation that step needs.

The middle step changes only part of a sum. For that, give `Equal.cong` a function that keeps the rest fixed: `n => Refl.add(x, n)` adds `x` on the left, so `Equal.cong` applies an equation underneath it.

<!-- @conclusion -->
Every Bend proof longer than a line or two looks like this: terms first, reasons after. The terms are what make a long proof readable later.
