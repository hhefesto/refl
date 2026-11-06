---
title: "mul_comm"
learning_goals:
  - "The same proof skeleton as `add_comm`, with `zero_mul` and `succ_mul` in place of `zero_add` and `succ_add`."
hints:
  - text: "`match y:`. The `0n` case's goal is `{0n == Refl.mul(0n, x) : Nat}`. The `1n+p` case's is `{Refl.add(Refl.mul(x, p), x) == Refl.mul(1n+p, x) : Nat}`."
  - text: "`0n` case: that's `zero_mul` backwards. `1n+p` case: `Equal.trans` through `Refl.add(Refl.mul(p, x), x)`, using the recursive call under `n => Refl.add(n, x)`, then `succ_mul` backwards."
  - text: "`case 0n:` is `Equal.sym(Nat, Refl.mul(0n, x), 0n, Multiplication.zero_mul(x))`. `case 1n+p:` is `Equal.trans(Nat, Refl.add(Refl.mul(x, p), x), Refl.add(Refl.mul(p, x), x), Refl.mul(1n+p, x), Equal.cong(Nat, Nat, n => Refl.add(n, x), Refl.mul(x, p), Refl.mul(p, x), mul_comm(x, p)), Equal.sym(Nat, Refl.mul(1n+p, x), Refl.add(Refl.mul(p, x), x), Multiplication.succ_mul(p, x)))`."
example_explanation: |-
  1. `Refl.mul(x, 0n)` computes to `0n`, but `Refl.mul(0n, x)` is stuck.
  2. `zero_mul(x)` is exactly the stuck side rewritten to `0n`, so it's the whole proof.
  The exercise generalises this: match on `y`; the zero case is this example, and the `1n+p` case uses `succ_mul` and the recursive call.
---
Commutativity again, this time for multiplication: `Refl.mul(x, y) == Refl.mul(y, x)`.

This level is short on purpose. You've proved this theorem once, for addition, and the plan carries over nearly word for word. In `add_comm` you used `zero_add` for the base case and `succ_add` for the step. You've just proved `zero_mul` and `succ_mul`, and they do the same two jobs here.

One thing changes. In `add_comm` the recursive call went under `n => 1n+n`, because addition puts a `1n+` on the outside. Read this level's **Goal** in the `1n+p` case: multiplication puts a `Refl.add(_, x)` on the outside instead, so the function you lift with is different. What is it?

<!-- @conclusion -->
The two commutativity proofs are the same *program* over different operations. That kind of repetition is what algebraic structures like semirings are for: state the laws once and prove things about all their instances.
