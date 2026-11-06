---
learning_goals:
  - "A proof of `A → B` is a function."
  - "`intro` brings a hypothesis into the context; `exact` hands over a finished term."
hints:
  - text: "The goal is `A → (A → B) → B`. Write `intro a f` to take both hypotheses. Then ask for the **Goal**: it wants a `B`, with `a : A` and `f : A → B` above the line."
  - text: "Nothing is known about `B`, so there's only one way to get one: apply the function you have to the value you have. `exact f a`."
example_explanation: |-
  1. Introduce the two functions and the value with `intro`.
  2. `f a` has type `B`.
  3. Apply `g` to obtain `C`. In the exercise, follow the types to choose which function consumes the available value.
---
Logic World starts from a change of viewpoint. A proposition is a type, and a proof of it is a value of that type. You've
used this since the Tutorial without saying so: a proof of `x = y → succ x = succ y` is a function.

Here's the oldest rule in logic, **modus ponens**: from `A`, and `A` implies `B`, conclude `B`. In Lean it's the type
`A → (A → B) → B`, for any propositions `A` and `B`. `Prop` is the type of propositions.

To prove an implication you take the hypothesis as an argument. The tactic for that is `intro`, followed by the name you want
to give it:

```lean
  intro a
```

Put that in and press **Goal**. `a : A` has moved above the line, and the goal has lost its first arrow. You can introduce
several at once by writing several names.

You've used `exact` already: it hands over a finished term, and Lean checks that its type matches the goal.

<!-- @conclusion -->
`A` and `B` are arbitrary propositions. Nothing about them is known, so the only possible proof is the one that uses the
hypotheses. That's the sense in which this is *logic*: the proof goes through because of the shape of the statement, whatever
`A` and `B` are.
