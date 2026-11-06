---
learning_goals:
  - "\"A if and only if B\" is a pair of functions."
  - "Reusing earlier lemmas as functions."
hints:
  - text: "The goal is a pair of functions. `(p => ?first, p => ?second)` opens one hole for each."
  - text: "You proved exactly that earlier in this world, for any `A` and `B`, and it's called `Logic.and_swap`. It takes the types as its first two arguments."
  - text: "`(p => Logic.and_swap(A, B, p), p => Logic.and_swap(B, A, p))`."
example_explanation: |-
  1. Read the statement as two function types.
  2. The forward function adds a trivial proof with `(a, Unit{})`.
  3. The reverse function projects it away with `Pair.fst`. In the exercise, supply the two appropriately typed functions.
---
"A if and only if B" means two things: `A` implies `B`, and `B` implies `A`. So a proof of it is two functions, one for each direction. You already know how to package two things: a pair.

The statement here is:

```
((A & B) -> (B & A)) & ((B & A) -> (A & B))
```

That is, "A and B" holds exactly when "B and A" does.

You could write out both functions from scratch. But look through your inventory first, since you may have proved one already. Proofs are values, so you can call a lemma you've proved inside a function, just like any other function.

<!-- @conclusion -->
A pair of implications is all "if and only if" ever is. Other provers wrap it in a named structure, but it's the same two functions.
