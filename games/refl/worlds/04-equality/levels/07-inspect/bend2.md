---
title: "Keeping the equation in a record"
learning_goals:
  - "An equation can travel inside a small record."
  - "`match` can take several values, in the order they were bound."
hints:
  - text: "`pick_g_ok`: `match b s:`, with `case True{} Saw{e}:` and `case False{} Saw{e}:`. A `match` on several values lists them in the order of the parameters."
  - text: "From there it's the last level's proof. In `g_nonzero`, the record you need is `Saw{{==}}`."
  - text: "`case True{} Saw{e}:` is `Empty.absurd({pick_g(True{}, n) == n : Nat}, h(Refl.isZero_true(n, e)))`, and `case False{} Saw{e}:` is `{==}`. `g_nonzero(n, h)` is `pick_g_ok(n, h, Refl.isZero(n), Saw{{==}})`."
example_explanation: |-
  1. Store the equation in a small record.
  2. Match on the Boolean together with that record.
  3. Unpack the equation and reflect the `True` result into a contradiction, and the `False` branch is `{==}`. The exercise uses `Saw` for this same bookkeeping.
---
Equations are values, so they can be stored like any other. That gives a second way to write the last level's proof, and it's an old trick in proof assistants, worth seeing once.

Here's a small record that holds one equation:

```
type Seen<-n: Nat, -b: Bool> is Type:
  Saw{evidence: {Refl.isZero(n) == b : Bool}}
```

A `Seen<n, b>` says "I saw that `isZero(n)` was `b`". The statement here is the previous level again, for the same function called `g`, but the helper takes this record rather than a bare equation.

You'll match on `b` and on the record together, to get `e` back out. A `match` on several values lists them in the order they were bound. If you got the order wrong, Bend will say so.

The rest of the proof is the same as before.

<!-- @conclusion -->
This looks like a lot of ceremony to carry one equation. It is. But it's how you'd write it in systems without a better way, and when you meet `Reveal`, `inspect` or a one-field record in older code, you now know what it's doing there.
