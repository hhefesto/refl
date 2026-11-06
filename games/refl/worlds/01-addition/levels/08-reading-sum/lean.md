---
learning_goals:
  - "A higher-order function `(MyNat → MyNat) → MyNat → MyNat` defined by recursion."
  - "Lemmas about sums are proved by the same induction as lemmas about `+`."
hints:
  - text: "`induction n with`, on the number of terms. What is `sumTo (fun _ => zero) zero`?"
  - text: "In the `succ` case, `sumTo (fun x => zero) n.succ` computes to `sumTo (fun x => zero) n + zero`, and `+ zero` computes away. That's exactly `ih`, as far as `exact` is concerned."
  - text: "`| zero => rfl`, and `| succ n ih => exact ih`."
example_explanation: |-
  1. `count (succ n)` unfolds to `count n + 1`, and `_ + 1` computes to `succ _`.
  2. So the goal at `succ n` is `succ (count n) = succ n`: `congrArg succ` of the hypothesis.
  The exercise's `sumTo (fun _ => zero)` unfolds the same way, with `+ zero` computing away instead of `+ 1`.
---
Finite sums turn up everywhere in real mathematics, and proof libraries spend a lot of effort
on lemmas about them: splitting a sum, reindexing it, pulling a term out. Those lemmas all look
like this level.

`sumTo f n` adds up `f 0 + f 1 + … + f (n - 1)`:

```lean
def sumTo (f : MyNat → MyNat) : MyNat → MyNat
  | zero => zero
  | succ n => sumTo f n + f n
```

Its first argument is itself a function, which says what each term of the sum is. This is the
first time you've passed a function to one of your own definitions.

Prove that the sum of zeros is zero. `fun _ => zero` ignores its argument and always returns
`zero`, where `_` means "I don't need this name".

Although a function appears in the statement, nothing about the proof has changed. Induct on the
number that the recursion looks at, then read each **Goal**. Lean's **Goal** won't compute
`sumTo` for you, so work out on paper what the `succ` case comes to.

<!-- @conclusion -->
A sum is a fold, and a lemma about a sum is an induction on its length. When you read lemmas about
sums in real code, look for this shape.

**Addition World complete.**
