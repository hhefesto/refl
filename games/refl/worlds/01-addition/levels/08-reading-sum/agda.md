---
example_explanation: |-
  1. Read the definition: `count (suc n)` unfolds to `count n + 1`, and `_ + 1` computes to `suc _`.
  2. So the goal at `suc n` is `suc (count n) ≡ suc n`: `cong suc` of the recursive call.
  The exercise's `sumTo (λ _ → zero)` unfolds the same way, with `+ zero` computing away instead of `+ 1`.
---
