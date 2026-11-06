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
      bend2: "Addition.add_left_comm"
      agda: "+-swap"
      lean: "add_left_comm"
hints:
  - text: "`x` and `y` can't change places while `y` is tucked inside `y + z`. Use associativity to bring them next to each other first, then swap them, then put the parentheses back."
  - text: "The intermediate terms are `x + (y + z)`, then `(x + y) + z`, then `(y + x) + z`, then `y + (x + z)`."
  - text: "The three steps are `sym (+-assoc x y z)`, `cong (_+ z) (+-comm x y)` and `+-assoc y x z`."
---
Same tools, no skeleton. The statement is `x + (y + z) ≡ y + (x + z)`, and this
time you write the whole `begin … ∎` block yourself.

Start by replacing the template with this, which is the shape of any chain:

```agda
+-swap x y z =
  begin
    x + (y + z) ≡⟨ ? ⟩
    y + (x + z) ∎
```

That has one step, and **Goal** on the hole shows the whole statement. Now grow
it: add a line in the middle with the sum you think comes next, keep a `?` in each
bracket, and **Check**. Each hole's **Goal** is now the equation for that one step,
which is the whole point of writing the terms down: you can see straight away
whether a step is one lemma or still too big.

So the real work is the plan. Which sums would you pass through, so that each move
from one to the next is exactly one lemma from your inventory? Copy symbols from
the skeleton, or type `≡` as `\==`, `⟨` as `\<`, `⟩` as `\>` and `∎` as `\qed`.

<!-- @conclusion -->
Four rearrangement lemmas (`+-assoc`, `+-comm`, `+-right-comm`, `+-swap`) are enough
to move terms anywhere in a sum. Multiplication World uses them constantly.
