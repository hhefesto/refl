---
title: "Reading: delta is symmetric"
learning_goals:
  - "Two splits in a row give a grid of cases."
  - "Contradictory cases are closed with `absurd` and `Eq.symm`."
hints:
  - text: "`unfold delta`, then `cases dec_eq i j with`, and in each of its two cases `cases dec_eq j i with`. That makes four cases in all."
  - text: "When the two decisions agree, `rfl` works. When they disagree, one says `i = j`, and the other refutes `j = i`. `Eq.symm` connects them, and `absurd` closes the case."
  - text: "`| isTrue p =>` with `| isTrue _ => rfl` and `| isFalse nq => exact absurd (Eq.symm p) nq`. Then `| isFalse np =>` with `| isTrue q => exact absurd (Eq.symm q) np` and `| isFalse _ => rfl`."
example_explanation: |-
  1. `delta i i` is defined by a `match` on `dec_eq i i`, so the proof splits on the same decision.
  2. In the `isTrue` case `delta i i` computes to `1`, so `rfl`.
  3. The `isFalse` case is impossible, since `rfl` proves `i = i`, so `absurd` closes it.
  For the exercise, split on both `dec_eq i j` and `dec_eq j i`.
---
Matrix libraries prove a lot of small facts about the Kronecker delta, because that's what the identity matrix is made of. Here's one of the first you'd need:

```lean
theorem delta_sym (i j : MyNat) : delta i j = delta j i
```

After `unfold delta`, **Goal** shows two whole `match` expressions, one stuck on `dec_eq i j` and the other on `dec_eq j i`. So you need to know both decisions. Split on one, then, inside each of its cases, split on the other:

```lean
  cases dec_eq i j with
  | isTrue p =>
    cases dec_eq j i with
    | isTrue _ => sorry
    | isFalse nq => sorry
  | isFalse np => sorry
```

Mind the indentation: the inner `cases` belongs to the first branch. Each decision has two outcomes, so that's four cases, a grid. Two of the four are easy. In the other two, the decisions contradict each other, so the case can't happen, and you've
already done this kind of thing with `absurd`.

<!-- @conclusion -->
**Equality World complete.** You can now read every `match`, `rw`, `cases` and `Eq.subst` you meet in real Lean code, and you've seen how Lean's choice about equality makes a hard theorem trivial.

This is the end of what's playable so far. The rest of the map shows what's planned, but those levels aren't written yet.
