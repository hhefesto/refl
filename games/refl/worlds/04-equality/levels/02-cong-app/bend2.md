---
title: "Function equality"
learning_goals:
  - "Equal functions agree everywhere."
  - "`Pointwise` says two functions agree at every input."
hints:
  - text: "`cong_app`: rewrite with `e`, marking the `g`: `%e : {f(x) == _(x) : B}`, then the goal is `{f(x) == f(x) : B}`."
  - text: "`pointwise_trans`: the goal is `{f(x) == h(x) : B}`. `p` and `q` are functions, so `p(x)` and `q(x)` are equations. Chain them."
  - text: "`cong_app` is `%e : {f(x) == _(x) : B}`, then `{==}`. `pointwise_trans` is `Equal.trans(B, f(x), g(x), h(x), p(x), q(x))`."
example_explanation: |-
  1. The hypothesis `p` is a function from a point to an equation there.
  2. Apply it at `x`.
  3. Reverse the resulting equality. In the exercise, compose two pointwise proofs at the same `x`.
---
What does it mean for two functions to be equal? There are two different answers, and this level is about the gap between them.

The first answer is `{f == g : A -> B}`: they're the same function. The second is `Pointwise`, which you'll find defined in the statement:

```
def Pointwise(-A: Type, -B: Type, -f: A -> B, -g: A -> B) -> Type:
  @x:A -> {f(x) == g(x) : B}
```

They agree at every input. This is called **pointwise** equality.

Equal functions certainly agree everywhere, and that's `cong_app`, your first lemma here. It's the mirror of `Equal.cong`: that one fixes the function and changes the argument, and this one fixes the argument and changes the function.

The other direction is **function extensionality**, and it isn't available: two functions may agree everywhere and yet be defined differently. So real developments state equalities of functions pointwise, and need its laws. Your second lemma is one of them.

Since `Pointwise` is a function type, `p` and `q` are functions you can apply. `x` is marked `+`, because you'll use it twice, and for that its type `A` has to be `Data`.

<!-- @conclusion -->
When you see functions compared one point at a time in real code, read it as "equal at every input".
