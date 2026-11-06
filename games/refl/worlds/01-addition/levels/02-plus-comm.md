---
id: plus-comm
index: 2
title: "+-comm"
learning_goals:
  - "Combining earlier lemmas with `trans`, `sym` and `cong`."
  - "The base case needs `zero-+`, the step needs `suc-+`."
unlocks:
  lemmas:
    - name: "+-comm"
      bend2: "Addition.add_comm"
      agda: "+-comm"
      lean: "add_comm"
      doc: "plus-comm.md"
hints:
  - text: "**Case split** on `y`, then read each clause's **Goal**. The `zero` clause says `x ≡ 0 + x`. Which lemma talks about `0 + x`, and which way does it point?"
  - text: "The `suc` clause says `suc (x + y) ≡ suc y + x`. Walk it in two steps: first from `suc (x + y)` to `suc (y + x)`, with the recursive call under `cong suc`, then to `suc y + x`, with `suc-+` backwards. **Refine** with `trans` gives you a hole for each step."
  - text: "`+-comm x zero = sym (zero-+ x)`, and `+-comm x (suc y) = trans (cong suc (+-comm x y)) (sym (suc-+ y x))`."
---
Commutativity: `x + y ≡ y + x`. Everybody knows it, and it is the first proof here
that takes real planning.

You have the two lemmas it needs, and they are in the inventory: `zero-+` and
`suc-+`, one for each case of the induction. The difficulty is that they rarely
fit the goal exactly as they stand. A lemma points in one direction and your goal
may want the other, so you will use `sym` to flip and `trans` to chain, as you did at the end of
the Tutorial.

Work like this. **Case split** on one of the variables, then ask for the **Goal**
in each clause. One side will have computed and the other will be stuck, and the
stuck side will be stuck in the exact shape one of your lemmas talks about.

When a clause needs more than one step, don't try to write it all at once. Put
`trans` in the box and press **Refine**: Agda opens a hole for each half, and each
hole gets its own goal.

<!-- @conclusion -->
This proof is correct but hard to read as a chain of `trans`. Two levels from now
you will write this kind of thing with `≡-Reasoning`.
