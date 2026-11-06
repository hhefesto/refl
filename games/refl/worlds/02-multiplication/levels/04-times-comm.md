---
id: times-comm
index: 4
title: "*-comm"
learning_goals:
  - "The same proof skeleton as `+-comm`, with `zero-*` and `suc-*` in place of `zero-+` and `suc-+`."
unlocks:
  lemmas:
    - name: "*-comm"
      bend2: "Multiplication.mul_comm"
      agda: "*-comm"
      lean: "mul_comm"
hints:
  - text: "**Case split** on `y`. The `zero` clause's goal is `0 ≡ 0 * x`. The `suc` clause's is `x * y + x ≡ suc y * x`."
  - text: "`zero` clause: that's `zero-* x` backwards. `suc` clause: use the recursive call under `cong (_+ x)`, then `suc-* y x` backwards."
  - text: "`*-comm x zero = sym (zero-* x)`, and `*-comm x (suc y) = trans (cong (_+ x) (*-comm x y)) (sym (suc-* y x))`."
---
Commutativity again, this time for multiplication: `x * y ≡ y * x`.

This level is short on purpose. You have proved this theorem once, for addition, and
the plan carries over nearly word for word. In `+-comm` you used `zero-+` for the
base case and `suc-+` for the step. You've just proved `zero-*` and `suc-*`, and they
do the same two jobs here.

One thing changes. In `+-comm` the recursive call went under `cong suc`, because
addition puts a `suc` on the outside. Read this level's **Goal** in the `suc` clause:
multiplication puts a `+ x` on the outside instead, so the function you lift with is
not `suc`. What is it?

<!-- @conclusion -->
The two commutativity proofs are the same *program* over different operations. That
kind of repetition is what algebraic structures like semirings are for: state the
laws once and prove things about all their instances.
