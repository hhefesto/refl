---
id: reading-distrib-sum
index: 9
title: "Reading: a factor out of a sum"
learning_goals:
  - "The lemma `*-distribˡ-sum` from `Algebra.Properties.Semiring.Sum`, in miniature."
  - "Induction on the length of a sum, with distributivity in the step."
hints:
  - text: "**Case split** on `n`. The `suc` clause's **Goal** is `sumTo (λ i → c * f i) n + c * f n ≡ c * (sumTo f n + f n)`."
  - text: "Use the recursive call on the left summand, under `cong (_+ c * f n)`. That leaves `c * sumTo f n + c * f n ≡ c * (sumTo f n + f n)`, and that's distributivity backwards."
  - text: "`sum-factor c f zero = refl`, and `sum-factor c f (suc n) = trans (cong (_+ c * f n) (sum-factor c f n)) (sym (*-distribˡ-+ c (sumTo f n) (f n)))`."
---
Pulling a constant out of a sum is a step you'll see in nearly every proof that does
algebra with sums: `c·a₀ + c·a₁ + …` equals `c·(a₀ + a₁ + …)`. The standard library
calls it `*-distribˡ-sum`, in `Algebra.Properties.Semiring.Sum`. Here it is for
`sumTo` from Addition World:

```agda
sum-factor : ∀ c f n → sumTo (λ i → c * f i) n ≡ c * sumTo f n
```

The statement looks heavier than anything so far, so read it one piece at a time.
`f` says what each term of the sum is. `λ i → c * f i` is the function whose terms have
been multiplied by `c`. And `n` is how many terms there are.

The proof is an induction on `n`, because the recursion in `sumTo` looks at `n`. The
`suc` step has the same shape as `*-assoc`: use the recursive call on one summand, then
use distributivity to line the two sides up. You've done every part of this before.

<!-- @conclusion -->
A lemma that looked forbidding in a textbook turned out to be an induction you could
already do.

**Multiplication World complete.** If you haven't been to Logic World yet, it's next
and changes the subject: types as propositions, pairs as *and*, functions as *implies*.
