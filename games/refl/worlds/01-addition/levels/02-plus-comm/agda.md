---
example_explanation: |-
  1. Draw the endpoints: `a → b` and `c → b`.
  2. Reverse the second edge to obtain `b → c`.
  3. Compose with `trans`. The exercise reverses a different edge; match endpoints before composing.
hints:
- hidden: false
  text: Commutativity aligns the two different recursion directions of addition.
- hidden: true
  text: Split `y`. The base uses zero on the left; the step uses the earlier successor-on-the-left
    lemma.
- hidden: true
  text: In the step start `trans (cong suc …) …`; check the orientation of the second
    equation.
learning_goals:
- Combining earlier lemmas with `trans`, `sym` and `cong`.
- The base case needs `zero-+`, the step needs `suc-+`.
title: +-comm
---
Commutativity aligns the two different recursion directions of addition.

Commutativity. Both inventory lemmas from before are needed, one per case.
Ask for the goal in each clause and normalise both sides before deciding
which lemma applies — the two sides do not compute the same way.


<!-- @conclusion -->

This proof is correct but unreadable as a chain of `trans`. Two levels from
now you will rewrite this kind of thing with `≡-Reasoning`.
