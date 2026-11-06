---
learning_goals:
  - "A proof of `A -> B` is a function."
  - "In a law, each `for` line is a hypothesis, and it becomes an argument of the `def`."
hints:
  - text: "Press **Goal**. It wants a `B`, with `a : A` and `f : @_:A -> B` in the context."
  - text: "Nothing is known about `B`, so there's only one way to get one: apply the function you have to the value you have. `f(a)`."
example_explanation: |-
  1. Each hypothesis is an argument of the `def`.
  2. `f(a)` has type `B`.
  3. Apply `g` to obtain `C`. In the exercise, follow the types to choose which function consumes the available value.
---
Logic World starts from a change of viewpoint. A proposition is a type, and a proof of it is a value of that type. You've used this since the Tutorial without saying so: a proof of `{1n+x == 1n+y : Nat}` from `{x == y : Nat}` was a function.

Here's the oldest rule in logic, **modus ponens**: from `A`, and `A` implies `B`, conclude `B`. In Bend it's a law:

```
law modus_ponens:
  for -A: Type
  for -B: Type
  for a: A
  for f: A -> B
  B
```

`Type` is the type of types, and `-A` makes `A` erased: it's only there for the checker. Each `for` line is an argument of the `def`, and the last line is what you must return.

`A -> B` is the type of functions, and the **Goal** panel prints it as `@_:A -> B`. Applying a function looks the same as everywhere else in Bend.

<!-- @conclusion -->
`A` and `B` are arbitrary types. Nothing about them is known, so the only possible proof is the one that uses the hypotheses. That's the sense in which this is *logic*: the proof goes through because of the shape of the statement, whatever `A` and `B` are.
