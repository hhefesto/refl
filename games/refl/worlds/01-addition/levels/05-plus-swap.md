---
id: plus-swap
index: 5
title: "+-swap"
learning_goals:
  - "Writing a `begin` block from scratch."
  - "Choosing intermediate terms so each step is one inventory lemma."
unlocks:
  lemmas:
    - name: "+-swap"
      agda: "+-swap"
      lean: "add_left_comm"
hints:
  - text: "Plan: `x + (y + z)` → `(x + y) + z` → `(y + x) + z` → `y + (x + z)`."
  - text: "`sym (+-assoc x y z)`, then `cong (_+ z) (+-comm x y)`, then `+-assoc y x z`."
    hidden: true
---
Same tools, no skeleton. Write the `begin … ∎` block yourself; check the
file after each step to see whether Agda agrees with your intermediate
terms (a wrong term is an error *at that step*, which is the point of
writing them down).

<!-- @conclusion -->
Three rearrangement lemmas (`+-assoc`, `+-comm`, `+-right-comm`, `+-swap`)
are enough to move terms anywhere in a sum. Multiplication World uses them
constantly.
