---
example_explanation: |-
  1. Distribute inside first: `*-distribˡ-+ x y z` turns `x * (y + z)` into `x * y + x * z`; `cong (λ n → n + x)` applies it under the outer `+ x`.
  2. Now both sides have the same three summands, associated differently: `+-assoc` finishes.
  This is exactly the `suc z` case of the exercise after unfolding `x * (y + suc z)`, with the induction hypothesis playing the role of `*-distribˡ-+`.
---
