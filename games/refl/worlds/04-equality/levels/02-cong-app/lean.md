---
title: "Function equality"
learning_goals:
  - "Equal functions agree everywhere."
  - "`Pointwise f g` says `f` and `g` agree at every input."
hints:
  - text: "`Pointwise f h` is a function type, so `intro x` works. The goal becomes `f x = h x`."
  - text: "Now take `e : f = g` apart with `cases e`, as in the last level. `f` and `g` become the same function, so `q` is what you need."
  - text: "`intro x`, then `cases e`, then `exact q x`."
example_explanation: |-
  1. Introduce a point `x`.
  2. Apply the pointwise hypothesis at that point.
  3. Reverse the resulting equality. In the exercise, apply the hypothesis at the point you introduced.
---
What does it mean for two functions to be equal? There are two different answers, and this level is about the gap between them.

The first answer is `f = g`: they're the same function. The second is `Pointwise f g`, which you'll find defined in the statement:

```lean
def Pointwise {A B : Type} (f g : A → B) : Prop := ∀ x, f x = g x
```

They agree at every input. This is called **pointwise** equality.

Equal functions certainly agree everywhere. That direction is `congrFun` in Lean's library. The other direction is **function extensionality**.
Lean has it as a theorem, `funext`, which rests on how Lean defines quotients. Plenty of other systems can't prove it at all, which is why pointwise
equality matters when you read code in those systems.

The statement here combines the two: from `f = g`, and `g` agreeing everywhere with `h`, conclude that `f` agrees everywhere with `h`. Since `Pointwise`
is a function type underneath, `intro` will work on it, and `q x` is a proof at the point `x`.

<!-- @conclusion -->
You've now used an equation between functions the same way you'd use one between numbers. `congrFun` is in your inventory from here on.
