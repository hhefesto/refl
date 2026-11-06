---
title: "mul_comm"
learning_goals:
  - "The same proof skeleton as `add_comm`, with `zero_mul` and `succ_mul` in place of `zero_add` and `succ_add`."
hints:
  - text: "`induction y with`. The `zero` case's goal is `x * zero = zero * x`, and the `succ` case's is `x * y.succ = y.succ * x`."
  - text: "`zero` case: that's `zero_mul x` backwards, with `exact`. `succ` case: `rw [mul_succ]` gives `x * y + x = y.succ * x`; then `ih`, then `succ_mul`."
  - text: "`| zero => exact Eq.symm (zero_mul x)`, and `| succ y ih => rw [mul_succ, ih, succ_mul]`."
example_explanation: |-
  1. `x * 0` computes to `0`, but `0 * x` is stuck.
  2. `zero_mul x` says the stuck side equals `0`, and that's the whole proof.
  The exercise generalises this: induct on `y`; the zero case is this example, and the `succ` case uses `succ_mul` and `ih`.
---
Commutativity again, this time for multiplication: `x * y = y * x`.

This level is short on purpose. You've proved this theorem once, for addition, and the plan carries over
nearly word for word. In `add_comm` you used `zero_add` for the base case and `succ_add` for the step. You've
just proved `zero_mul` and `succ_mul`, and they do the same two jobs here.

One thing changes. In `add_comm`, unfolding put a `succ` on the outside. Read this level's **Goal** after
`rw [mul_succ]`: multiplication puts a `+ x` on the outside instead. That doesn't bother `rw`, though. It finds
`x * y` wherever it is, so `ih` works straight away.

Remember the trap from `add_comm`: the base case says `zero`, and `zero_mul` says `0`, so use `exact` there.

<!-- @conclusion -->
The two commutativity proofs are the same *program* over different operations. That kind of repetition is
what algebraic structures like semirings are for: state the laws once and prove things about all their
instances.
