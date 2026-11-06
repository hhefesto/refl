---
learning_goals:
  - "Pulling a constant out of a sum, in miniature."
  - "Induction on the length of a sum, with distributivity in the step."
hints:
  - text: "`induction n with`. The `succ` case computes to `sumTo (fun i => c * f i) n + c * f n = c * (sumTo f n + f n)`."
  - text: "Use `ih` on the left summand, under `(· + c * f n)`. That leaves `c * sumTo f n + c * f n = c * (sumTo f n + f n)`, which is `mul_add` backwards."
  - text: "`| zero => rfl`, and `| succ n ih => exact Eq.trans (congrArg (· + c * f n) ih) (Eq.symm (mul_add c (sumTo f n) (f n)))`."
example_explanation: |-
  1. Induct on `n`: at zero every `sumTo` is `zero`, so `rfl`.
  2. At `succ n`, the new term is `c * 0`, which computes to `0`, and adding it computes away.
  3. So `ih` is already the goal. The exercise follows the same plan with `mul_add`: unfold, use the hypothesis under `congrArg`, distribute.
---
Pulling a constant out of a sum is a step you'll see in nearly every proof that does algebra with sums:
`c·a₀ + c·a₁ + …` equals `c·(a₀ + a₁ + …)`. Here it is for `sumTo` from Addition World:

```lean
theorem sum_factor (c : MyNat) (f : MyNat → MyNat) (n : MyNat) :
    sumTo (fun i => c * f i) n = c * sumTo f n
```

The statement looks heavier than anything so far, so read it one piece at a time. `f` says what each term of the sum is.
`fun i => c * f i` is the function whose terms have been multiplied by `c`. And `n` is how many terms there are.

The proof is an induction on `n`, because the recursion in `sumTo` looks at `n`. `rw` can't see inside `sumTo (…) n.succ`
until it's unfolded, so work out what the `succ` case computes to, and build a term that `exact` will check. The step has
the same shape as `mul_assoc`: the hypothesis on one summand, then distributivity to line the two sides up.

<!-- @conclusion -->
A lemma that looked forbidding in a textbook turned out to be an induction you could already do.

**Multiplication World complete.** If you haven't been to Logic World yet, it's next and changes the subject: propositions
and proofs, with `∧` as a pair and `→` as a function.
