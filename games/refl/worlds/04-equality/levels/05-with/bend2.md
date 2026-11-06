---
title: "A helper for the decision"
learning_goals:
  - "`match` works on a parameter or field, not a computed value, so a decision gets its own function."
  - "A lemma about such a function takes the decision as a parameter too."
hints:
  - text: "`pick_yes`: `match d:`, with `case Refl.Yes{p}:` and `case Refl.No{q}:`. The goals are `{1n == 1n : Nat}` and `{0n == 1n : Nat}`."
  - text: "The second is false, so that case must be impossible. `q` refutes `A`, and you have `a : A`, so `q(a)` is `Empty`. `Empty.absurd(T, e)` turns that into anything of type `T`."
  - text: "`case Refl.No{q}:` is `Empty.absurd({pick(A, Refl.No{q}) == 1n : Nat}, q(a))`. `delta_diag(i)` is `pick_yes({i == i : Nat}, {==}, Logic.dec_eq(i, i))`."
example_explanation: |-
  1. `choose` matches on a decision, so the proof does too.
  2. In the `Yes` case the function computes, so `{==}`.
  3. In the `No` case its refutation contradicts the supplied witness. The exercise proves this kind of fact, then applies it to a real decision.
---
Here's the Kronecker delta, a function that's `1n` when its two indices are equal and `0n` when they aren't. It's the identity matrix, written as a formula.

Bend has a rule here: a `match` can only look at a parameter or a field, not at a computed value. So you can't match on `Logic.dec_eq(i, j)` directly. Instead, the decision becomes a parameter of a helper:

```
def pick(-A: Type, d: Refl.Dec<A>) -> Nat:
  match d:
    case Refl.Yes{p}:
      1n
    case Refl.No{q}:
      0n

def delta(i: Nat, j: Nat) -> Nat:
  pick({i == j : Nat}, Logic.dec_eq(i, j))
```

Prove that the delta of an index with itself is `1n`. **Goal** shows `{pick({i == i : Nat}, Logic.dec_eq(i, i)) == 1n : Nat}`: stuck, because `i` is a variable, and the decision can't compute.

So do the same thing in the proof. `pick_yes` is a lemma about *any* decision `d` for a true `A`: since `d` is a parameter, you can match on it. One case is easy. The other can't happen, but Bend needs you to prove that. Then `delta_diag` applies it to the real decision.

<!-- @conclusion -->
This is one of the most common patterns in proofs about programs: a function that branches on a decision, and a lemma about it that branches the same way. Agda has a keyword for it, `with`, and generates that helper for you. In Bend you write it yourself, and you can see exactly what's going on.
