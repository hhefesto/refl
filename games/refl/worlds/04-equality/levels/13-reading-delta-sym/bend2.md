---
title: "Reading: delta is symmetric"
learning_goals:
  - "`match` on two decisions gives a grid of cases."
  - "Contradictory cases are closed with `Empty.absurd` and `Equal.sym`."
hints:
  - text: "`pick_sym`: `match d b:`, with four cases: `case Refl.Yes{p} Refl.Yes{q}:`, `case Refl.Yes{p} Refl.No{nq}:`, `case Refl.No{np} Refl.Yes{q}:` and `case Refl.No{np} Refl.No{nq}:`."
  - text: "When the two decisions agree, the goal is `{1n == 1n : Nat}` or `{0n == 0n : Nat}`, and `{==}` works. When they disagree, one says `i` equals `j`, and the other refutes `j` equals `i`. `Equal.sym` connects them."
  - text: "`case Refl.Yes{p} Refl.No{nq}:` is `Empty.absurd({1n == 0n : Nat}, nq(Equal.sym(Nat, i, j, p)))`. `case Refl.No{np} Refl.Yes{q}:` is `Empty.absurd({0n == 1n : Nat}, np(Equal.sym(Nat, j, i, q)))`. `delta_sym(i, j)` is `pick_sym(i, j, Logic.dec_eq(i, j), Logic.dec_eq(j, i))`."
example_explanation: |-
  1. `delta(i, i)` is `pick` of the decision `dec_eq(i, i)`.
  2. `pick_yes` says `pick` gives `1n` for any decision of a true statement, and `{i == i : Nat}` is true, by `{==}`.
  For the exercise, match on both `dec_eq(i, j)` and `dec_eq(j, i)`, as parameters of a helper.
---
Matrix libraries prove a lot of small facts about the Kronecker delta, because that's what the identity matrix is made of. Here's one of the first you'd need: `{delta(i, j) == delta(j, i) : Nat}`.

**Goal** on `delta_sym` says `{Equality.pick({i == j : Nat}, Logic.dec_eq(i, j)) == Equality.pick({j == i : Nat}, Logic.dec_eq(j, i)) : Nat}`. So there are two stuck decisions now, and you need to know both. As before, they become parameters of a helper, `pick_sym`. And a `match` can take more than one value:

```
match d b:
  case Refl.Yes{p} Refl.Yes{q}:
    ?TODO
```

Each decision has two outcomes, so that's four cases, a grid. You have to write them out, one pattern per decision. Two of the four are the easy cases. In the other two, the decisions contradict each other, so the case can't happen, and you've already proved this kind of thing with `Empty.absurd`.

<!-- @conclusion -->
**Equality World complete.** You can now read every rewrite and motive you meet in real Bend code, and you've proved Hedberg's theorem along the way.

This is the end of what's playable so far. The rest of the map shows what's planned, but those levels aren't written yet.
