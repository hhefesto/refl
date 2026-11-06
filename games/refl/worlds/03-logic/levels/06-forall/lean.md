---
learning_goals:
  - "A universal statement `∀ n, P n` is a dependent function."
  - "Predicates are functions into `Prop`."
hints:
  - text: "The goal is a pair, so start with `constructor` and a `·` line for each side. In each, `intro n` takes the number."
  - text: "In the first, the goal is `P n`, with `h : ∀ n, P n ∧ Q n` above the line. `h n` is a pair, so project out the part you want with `.left`."
  - text: "`· intro n` then `exact (h n).left`, and `· intro n` then `exact (h n).right`."
example_explanation: |-
  1. Introduce the index with `intro n`.
  2. Apply both functions at that same index.
  3. Pair their results. The exercise runs this construction backwards, extracting a function for each projection.
---
Here's something new in the statement: `P Q : MyNat → Prop`. A function from numbers to *propositions*. It takes a number and
gives back a statement about it. For example, `fun n => n = 2` takes `3` to the statement `3 = 2`. A function like this is called
a **predicate**.

You've seen `∀` since the Tutorial, and it's a function here too, with one twist. In `∀ n, P n` the *type* of the result depends on
the *value* of the argument: given `3` it returns a proof of `P 3`. That's called a **dependent function**. So you use `∀` the way
you use any function, by applying it, and you prove one the way you prove any function, with `intro`.

The statement says that if every number satisfies both `P` and `Q`, then every number satisfies `P`, and every number satisfies `Q`.
Read the parentheses carefully: the hypothesis is one function that returns pairs, and the goal is a pair of functions.

Build the outside first, with `constructor`, as you did with `True` and `False`.

<!-- @conclusion -->
`MyNat → Prop` is the type of predicates on `MyNat`. Replace `MyNat` by strings and a predicate is exactly what theory of computation
calls a *language*, which is where this world's last level is headed.
