---
learning_goals:
  - "A universal statement `@n:Nat -> P(n)` is a dependent function."
  - "Predicates are functions into `Type`."
hints:
  - text: "Press **Goal**. It prints `Sigma<&1, &1, P(n), _ => Q(n)>`, Bend's name for `P(n) & Q(n)`, so you need a pair."
  - text: "`p` and `q` are functions, and `n` is what you apply them to."
  - text: "`(p(n), q(n))`."
example_explanation: |-
  1. `p` is a function from a number `n` to a proof of `P(n)`.
  2. So applying it to `2n` gives a proof of `P(2n)`.
  That's all a universal statement is. In the exercise, apply each function at the same `n`, and pair the results.
---
Here's something new in the statement: `-P: Nat -> Type`. A function from numbers to *types*. Since a type is a proposition, it takes a number and gives back a statement about it. For example, `n => {n == 2n : Nat}` takes `3n` to the statement `{3n == 2n : Nat}`. A function like this is called a **predicate**.

`@n:Nat -> P(n)` is a function too, with one twist: the *type* of the result depends on the *value* of the argument. Given `3n`, it returns a proof of `P(3n)`. That's called a **dependent function**, and it's how you say "for all `n`".

The statement says that if every number satisfies `P`, and every number satisfies `Q`, then any `n` satisfies both. `n` is marked `+`, because you need it twice.

<!-- @conclusion -->
`Nat -> Type` is the type of predicates on `Nat`. Replace `Nat` by strings and a predicate is exactly what theory of computation calls a *language*, which is where this world's last level is headed.
