---
example_explanation: |-
  1. The left side is an expanded product.
  2. The available distributivity lemma points from product to sum.
  3. Reverse it with `sym`. In the exercise use this direction after lifting the induction hypothesis through the new summand.
hints:
- hidden: false
  text: Pulling a factor out of a finite sum is distributivity repeated by induction.
- hidden: true
  text: Split the length `n`. Lift the smaller sum's equality under addition of the
    final term.
- hidden: true
  text: Use `trans (cong (_+ c * f n) …) (sym …)` in the step.
learning_goals:
- The lemma `*-distribˡ-sum` from `Algebra.Properties.Semiring.Sum`, in miniature.
- Induction on the length of a sum, with distributivity in the step.
title: 'Reading: a factor out of a sum'
---
Pulling a factor out of a finite sum is distributivity repeated by induction.

Spectra2's completion-of-squares proof (`Linear.lagda`) pulls constants out
of weighted sums with `*-distribˡ-sum`. Here is that lemma for `sumTo`
from Addition World:

```agda
sum-factor : ∀ c f n → sumTo (λ i → c * f i) n ≡ c * sumTo f n
```


<!-- @conclusion -->

Two worlds of arithmetic are done. Logic World is next and changes the
subject: types as propositions, pairs as *and*, functions as *implies*.
