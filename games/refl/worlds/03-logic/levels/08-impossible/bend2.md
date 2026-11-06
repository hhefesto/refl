---
learning_goals:
  - "`{a != b : T}` is `{a == b : T} -> Empty`."
  - "Different constructors can never be equal, and a function that tells them apart proves it."
hints:
  - text: "The goal is `@_:{0n == 1n+n : Nat} -> Empty`, so start with `e =>`, and a new line below it. Now you must produce `Empty`, and `disc(0n)` is `Empty`."
  - text: "Rewrite with `e` flipped, marking the `0n`: `%Equal.sym(Nat, 0n, 1n+n, e) : disc(_)`. Then the goal is `disc(1n+n)`, which is `Unit`."
  - text: "`e =>`, then `%Equal.sym(Nat, 0n, 1n+n, e) : disc(_)`, then `Unit{}`, with the last two indented under the first."
example_explanation: |-
  1. `disc` here sends `0n` to `Unit` and a successor to `Empty`, the other way round from the exercise.
  2. So the goal `Empty` is `disc(1n+n)`. Rewriting with `e` flipped changes it to `disc(0n)`, which is `Unit`.
  3. `Unit{}` finishes. The exercise has the sides of the equation the other way round.
---
You now have enough logic to say two numbers are *different*. `{a != b : T}` is shorthand for `{a == b : T} -> Empty`: a function that takes a proof of the equation and returns `Empty`.

Why should `{0n != 1n+n : Nat}` hold? `0n` and `1n+n` are built with different constructors, so no amount of computing can ever bring them together. There's no `{==}` for them.

Bend asks you to show this, with a small trick. The statement gives you a **discriminator**, a function that sends each constructor to a different type:

```
def disc(n: Nat) -> Type:
  match n:
    case 0n:
      Empty
    case 1n+p:
      Unit
```

Now suppose you had a proof of `{0n == 1n+n : Nat}`, and you need `Empty`. `Empty` is `disc(0n)`. If you rewrite `0n` to `1n+n` in there, your goal becomes `disc(1n+n)`, which is `Unit`, and that's trivially provable. An impossible equation has turned falsity into truth.

Remember the direction of `%e : P`: `_` marks the *right* side of `e`, so you'll need `e` flipped.

<!-- @conclusion -->
Every proof that two constructors differ looks like this, and you can reuse this one: from now on, it's `Logic.zero_ne_succ`. The next level puts it to use.
