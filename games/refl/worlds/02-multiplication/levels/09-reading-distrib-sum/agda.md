---
title: "Reading: a factor out of a sum"
learning_goals:
  - "The lemma `*-distribˡ-sum` from `Algebra.Properties.Semiring.Sum`, in miniature."
  - "Induction on the length of a sum, with distributivity in the step."
hints:
  - text: "Induction on `n`. The step: left `sumTo (λ i → c * f i) n + c * f n`, right `c * (sumTo f n + f n)`. Distribute the right side with `*-distribˡ-+` and use the hypothesis on the left summand."
  - text: "`trans (cong (_+ c * f n) (sum-factor c f n)) (sym (*-distribˡ-+ c (sumTo f n) (f n)))`."
    hidden: true
example_explanation: |-
  1. Induction on `n`: at zero every `sumTo` is `zero`, so `refl`.
  2. At `suc n`, unfold: the left is `sumTo (λ i → f i + g i) n + (f n + g n)`, the right is `(sumTo f n + f n) + (sumTo g n + g n)`.
  3. Rewrite the recursive sum with the induction hypothesis under `cong (λ s → s + (f n + g n))`, then regroup four summands with a small helper built from `+-assoc` and `+-swap`.
  The exercise follows the same plan with `*-distribˡ-+` instead of the regrouping helper: unfold, use the induction hypothesis under `cong`, distribute.
---
Spectra2's completion-of-squares proof (`Linear.lagda`) pulls constants out
of weighted sums with `*-distribˡ-sum`. Here is that lemma for `sumTo`
from Addition World:

```agda
sum-factor : ∀ c f n → sumTo (λ i → c * f i) n ≡ c * sumTo f n
```

<!-- @conclusion -->
Two worlds of arithmetic are done. Logic World is next and changes the
subject: types as propositions, pairs as *and*, functions as *implies*.
