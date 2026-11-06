---
title: "match and cases"
learning_goals:
  - "`match e with` branches on the value of an expression."
  - "A function defined by `match` computes only once its scrutinee is known; lemmas about it take the same case split."
  - "`unfold` opens a definition; `cases e` splits on an expression."
hints:
  - text: "`unfold delta`, then press **Goal**. It shows the whole `match`, stuck on `dec_eq i i`. So split on the same expression: `cases dec_eq i i with`."
  - text: "Use two cases, `| isTrue h => sorry` and `| isFalse n => sorry`. In the first, `rfl` is enough. In the second, `n : ¬i = i`, which is impossible."
  - text: "`| isTrue _ => rfl`, and `| isFalse n => exact absurd rfl n`."
example_explanation: |-
  1. `choose` is defined by matching on a decision, so the proof splits on the same decision.
  2. In the `isTrue` case, the function computes, so `rfl`.
  3. In the `isFalse` case its refutation contradicts the supplied witness, and `absurd` turns that into anything. In the exercise, `rfl` itself is that witness.
---
Here's the Kronecker delta, a function that's `1` when its two indices are equal and `0` when they aren't. It's the identity matrix, written as a formula:

```lean
def delta (i j : MyNat) : MyNat :=
  match dec_eq i j with
  | isTrue _ => 1
  | isFalse _ => 0
```

`match` on an *expression*, not just a variable, computes `dec_eq i j` and branches on the result. That's a `Decidable`, so there are two cases.

Prove that the delta of an index with itself is `1`. **Goal** shows `delta i i = 1`, and `rw` can't do anything with that. First open the definition with `unfold delta`, and look
at the goal again: a whole `match`, stuck on `dec_eq i i`. You know it'll be `isTrue`, but Lean doesn't, because `i` is a variable.

So split on the same thing the function splits on. `cases` works on an expression too, not only a variable: `cases dec_eq i i with`. It replaces `dec_eq i i` everywhere in the goal, and
then the `match` can compute. One case is easy. The other can't happen, but Lean needs you to prove that. `absurd a na` takes a proof and its refutation and gives you whatever the goal wants.

<!-- @conclusion -->
This is one of the most common patterns in proofs about programs: a function defined by a `match`, and lemmas about it that split on the same thing.
