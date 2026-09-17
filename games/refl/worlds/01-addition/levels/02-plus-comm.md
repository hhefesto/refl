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
      agda: "+-comm"
      lean: "add_comm"
      doc: "plus-comm.md"
hints:
  - text: "Induction on `y`. Base case: `x + zero ≡ zero + x` — the left side computes to `x`, the right side is `zero-+ x` backwards."
  - text: "Step: the goal is `suc (x + y) ≡ suc y + x`. Rewrite the left with the induction hypothesis under `cong suc`, then use `suc-+ y x` backwards. Use **Refine** with `trans` to get two holes."
  - text: "`+-comm x zero = sym (zero-+ x)` and `+-comm x (suc y) = trans (cong suc (+-comm x y)) (sym (suc-+ y x))`."
    hidden: true
---
Commutativity. Both inventory lemmas from before are needed, one per case.
Ask for the goal in each clause and normalise both sides before deciding
which lemma applies — the two sides do not compute the same way.

<!-- @conclusion -->
This proof is correct but unreadable as a chain of `trans`. Two levels from
now you will rewrite this kind of thing with `≡-Reasoning`.
