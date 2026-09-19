---
example_explanation: |-
  1. Induction on `n`: at zero every `sumTo` is `zero`, so `refl`.
  2. At `suc n`, unfold: the left is `sumTo (λ i → f i + g i) n + (f n + g n)`, the right is `(sumTo f n + f n) + (sumTo g n + g n)`.
  3. Rewrite the recursive sum with the induction hypothesis under `cong (λ s → s + (f n + g n))`, then regroup four summands with a small helper built from `+-assoc` and `+-swap`.
  The exercise follows the same plan with `*-distribˡ-+` instead of the regrouping helper: unfold, use the induction hypothesis under `cong`, distribute.
---
