---
learning_goals:
  - "A `def` returning a function and a `def` with one more argument mean the same thing."
  - "`rfl` sees through definitions: both sides unfold to `h (xs (t + δ))`."
hints:
  - text: "Both definitions are in the statement; unfold them in your head at `t`."
  - text: "`analog₁ δ h xs t` applies the lambda to `t` and gives `h (xs (t + δ))`; `analog₁' δ h xs t` is that expression by definition. Same term."
    hidden: true
  - text: "`  rfl`."
    hidden: true
example_explanation: |-
  1. `shifted k` returns a lambda.
  2. `shifted'` names the lambda's argument explicitly.
  3. Applying either computes to `n + k`, so `rfl` works. The exercise additionally samples and transforms a signal, but argument movement is the same.
---
This is the reading level: nothing to invent, only to see that two
definitions agree. `analog₁` returns a function (`fun t => …`), `analog₁'`
takes `t` as a fourth argument. Applied to `t`, both unfold to the same term,
so the equation is `rfl`. This is the Lean spelling of the Timely Computation
`analog₁` from the notes.

<!-- @conclusion -->
Definitions unfold; `rfl` checks the result. That is all the Tutorial in Lean:
`rfl`, `rw`, `congrArg`, `induction`, and reading.
