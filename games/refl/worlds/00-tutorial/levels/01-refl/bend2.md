---
learning_goals:
  - "A `law` states, the `def` below it proves; `?goal` is the hole to fill."
  - "`{==}` is refl: it proves `{a == b : T}` when both sides compute to the same value."
hints:
  - text: "The statement is the `law`. Edit the `def`: replace `?goal` with a proof of `{Refl.add(2n, 2n) == 4n : Nat}`."
  - text: "Bend computes `Refl.add(2n, 2n)` to `4n`, so the goal is `{4n == 4n : Nat}` (**Check** shows it normalised). `{==}` proves any equality whose sides compute to the same term."
    hidden: true
  - text: "Type `{==}` in the expression box, select the hole and press **Give**, or edit the line to `  {==}` and **Check**."
    hidden: true
example_explanation: |-
  1. The law states the equality and its type.
  2. `Refl.add(3n, 1n)` computes to `4n`.
  3. The matching definition supplies `{==}`. Use the same constructor for the exercise's different numeric equality.
---
Your first Bend proof. A `law` states a claim and a `def` with the same name
proves it. The `def` currently ends in a *loud hole* `?goal`: **Check**
(`C-c C-l`) reports it as the open goal, with its type normalised. Select it
and press **Goal** (`C-c C-,`) to see the type and the context, then **Give**
(`C-c C-SPC`) an expression, or edit the line directly.

<!-- @conclusion -->
`{==}` is Bend's `refl`. The checker computed `Refl.add(2n, 2n)` to `4n` for
you; the rest of this world is about bringing goals to that point.
