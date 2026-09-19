---
title: "+-comm"
learning_goals:
  - "Combining earlier lemmas with `trans`, `sym` and `cong`."
  - "The base case needs `zero-+`, the step needs `suc-+`."
hints:
  - text: "Induction on `y`. Base case: `x + zero ≡ zero + x` — the left side computes to `x`, the right side is `zero-+ x` backwards."
  - text: "Step: the goal is `suc (x + y) ≡ suc y + x`. Rewrite the left with the induction hypothesis under `cong suc`, then use `suc-+ y x` backwards. Use **Refine** with `trans` to get two holes."
  - text: "`+-comm x zero = sym (zero-+ x)` and `+-comm x (suc y) = trans (cong suc (+-comm x y)) (sym (suc-+ y x))`."
    hidden: true
example_explanation: |-
  1. Normalise both sides: `x + 1` computes to `suc x` (recursion on the second argument), but `1 + x` is stuck.
  2. So work on the stuck side: `suc-+ zero x : 1 + x ≡ suc (zero + x)`, then `zero-+ x` inside `suc`.
  3. Chain with `trans`, and flip with `sym` because the goal wants `x + 1` on the left.
  For the exercise, split `y`: the zero case is this idea with `zero-+`, the `suc` case uses `suc-+` and the induction hypothesis under `cong suc`.
---
Commutativity. Both inventory lemmas from before are needed, one per case.
Ask for the goal in each clause and normalise both sides before deciding
which lemma applies — the two sides do not compute the same way.

<!-- @conclusion -->
This proof is correct but unreadable as a chain of `trans`. Two levels from
now you will rewrite this kind of thing with `≡-Reasoning`.
