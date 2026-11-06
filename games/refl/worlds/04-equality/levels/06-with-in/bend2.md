---
title: "Remembering a test"
learning_goals:
  - "A Boolean result says nothing by itself; a helper can take an equation about it."
  - "Boolean tests must be remembered to be reasoned about."
hints:
  - text: "`pick_b_ok`: `match b:`, with `case True{}:` and `case False{}:`. In the `True` case, `e` has become `{Refl.isZero(n) == True{} : Bool}`."
  - text: "`Refl.isZero_true(n, e)` turns that into `{n == 0n : Nat}`, which `h` refutes. So that case is impossible. The `False` case computes. In `f_nonzero`, `b` is the test itself and `e` is `{==}`."
  - text: "`case True{}:` is `Empty.absurd({pick_b(True{}, n) == n : Nat}, h(Refl.isZero_true(n, e)))`, and `case False{}:` is `{==}`. `f_nonzero(n, h)` is `pick_b_ok(n, h, Refl.isZero(n), {==})`."
example_explanation: |-
  1. Match on the Boolean `b`.
  2. `e` keeps evidence relating the original test to `b`.
  3. In the `True` case `isZero_true` contradicts `h`, and in the `False` case `{==}` finishes. In the exercise the target also mentions a function defined by the test.
---
Last level, you matched on a `Dec`, which carries its evidence inside. A test that returns a boolean doesn't: a plain `True{}` can't tell you why it's true. If you match on it, you learn which branch you're in, but you've no way to use that fact in a proof.

The way out is to remember what the test said, as an equation. Here's the function:

```
def pick_b(b: Bool, +n: Nat) -> Nat:
  match b:
    case True{}:
      1n
    case False{}:
      n

def f(+n: Nat) -> Nat:
  pick_b(Refl.isZero(n), n)
```

Prove that `f(n)` is `n` whenever `n` isn't zero. Again, the work goes in a helper. `pick_b_ok` takes any `b`, along with `e : {Refl.isZero(n) == b : Bool}`. When you match on `b`, `e`'s type changes with it, and so you'll know what the test said in each branch. In the `True` branch you're in an impossible case: `n` isn't zero, yet the test says it is.

To turn the test's result into a real equation, the library has `Refl.isZero_true(n, e)`. When you call the helper from `f_nonzero`, the equation is trivial: `{==}`, because the test equals itself.

<!-- @conclusion -->
You'll see this wherever code branches on a boolean test and a proof has to follow it. Generalize over the result, and keep an equation that says where it came from.
