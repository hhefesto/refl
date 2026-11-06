---
title: "succ is injective"
learning_goals:
  - "Constructors are injective, and `Equal.cong` with a *destructor* proves it."
hints:
  - text: "You want to go from `{1n+x == 1n+y : Nat}` to `{x == y : Nat}`, which means taking a `1n+` off both sides. Which function in the statement does that?"
  - text: "`pred(1n+x)` computes to `x`. So apply `pred` to both sides of `h` with `Equal.cong`."
  - text: "`Equal.cong(Nat, Nat, pred, 1n+x, 1n+y, h)`."
example_explanation: |-
  1. Define a predecessor function by cases.
  2. Apply it twice to both sides using `Equal.cong`.
  3. The constructors disappear by computation. The exercise removes only one successor.
---
From `{1n+x == 1n+y : Nat}` conclude `{x == y : Nat}`. This says the successor never sends two different numbers to the same one, which is what **injective** means.

All your lemmas so far have added things to both sides of an equation: `Equal.cong` with `n => 1n+n` wraps a `1n+` around each. This time you need to take one off. Remember that `Equal.cong` works with *any* function, not only constructors.

The statement defines one such function:

```
def pred(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      p
```

`pred` computes when it sees a `1n+`. What would both sides of `h` turn into if you applied `pred` to them?

<!-- @conclusion -->
Any constructor is injective, and this is how you show it: write the function that takes it apart. You'll write a similar function in Logic World, to prove that two constructors differ.
