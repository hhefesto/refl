---
title: "succ is injective"
learning_goals:
  - "Constructors are injective, and `congrArg` with a *destructor* proves it."
  - "`cases h` also works: it unifies the two sides."
hints:
  - text: "You want to go from `succ x = succ y` to `x = y`, which means taking a `succ` off both sides. Which function in the statement does that?"
  - text: "`pred (succ x)` computes to `x`. So apply `pred` to both sides of `h` with `congrArg`."
  - text: "`exact congrArg pred h`."
example_explanation: |-
  1. Define a predecessor function by cases.
  2. Apply it twice to both sides using `congrArg`.
  3. The constructors disappear by computation. The exercise removes only one successor.
---
From `succ x = succ y` conclude `x = y`. This says `succ` never sends two different numbers
to the same one, which is what **injective** means.

All your lemmas so far have added things to both sides of an equation: `congrArg succ`
wraps a `succ` around each. This time you need to take one off. Remember that `congrArg`
works with *any* function, not only constructors.

The statement defines one such function:

```lean
def pred : MyNat → MyNat
  | zero => zero
  | succ n => n
```

`pred` computes when it sees a `succ`. What would both sides of `h` turn into if you applied
`pred` to them? And `exact` doesn't mind that the type you give it only *computes* to the goal.

<!-- @conclusion -->
There is a second proof. `cases h` matches `h` against `rfl`: Lean then knows `x` and `y` are
the same variable, because `rfl` can only prove `succ x = succ y` if they are. Then `rfl`
closes it.

Matching on an equation like that is your first taste of *dependent* pattern matching, which
is Equality World's subject.
