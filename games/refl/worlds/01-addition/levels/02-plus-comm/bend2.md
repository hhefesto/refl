---
title: "add_comm"
learning_goals:
  - "Combining earlier lemmas with `Equal.trans`, `Equal.sym` and `Equal.cong`."
  - "The base case needs `zero_add`, the step needs `succ_add`."
hints:
  - text: "`match y:`. The `0n` case's goal is `{x == Refl.add(0n, x) : Nat}`. Which lemma talks about `Refl.add(0n, x)`, and which way does it point?"
  - text: "The `1n+p` case's goal is `{1n+Refl.add(x, p) == Refl.add(1n+p, x) : Nat}`. Walk it in two steps with `Equal.trans`: first to `1n+Refl.add(p, x)`, using the recursive call under `Equal.cong`, then to `Refl.add(1n+p, x)`, using `succ_add` backwards."
  - text: "`case 0n:` is `Equal.sym(Nat, Refl.add(0n, x), x, Tutorial.zero_add(x))`. `case 1n+p:` is `Equal.trans(Nat, 1n+Refl.add(x, p), 1n+Refl.add(p, x), Refl.add(1n+p, x), Equal.cong(Nat, Nat, n => 1n+n, Refl.add(x, p), Refl.add(p, x), add_comm(x, p)), Equal.sym(Nat, Refl.add(1n+p, x), 1n+Refl.add(p, x), Addition.succ_add(p, x)))`."
example_explanation: |-
  1. `Refl.add(x, 1n)` computes to `1n+x`, but `Refl.add(1n, x)` is stuck.
  2. So work on the stuck side: `succ_add(0n, x)` turns it into `1n+Refl.add(0n, x)`, then `zero_add` goes inside with `Equal.cong`.
  3. Chain with `Equal.trans`, and flip with `Equal.sym`, because the goal wants `Refl.add(x, 1n)` on the left.
  For the exercise, match on `y`, using `zero_add` at zero and `succ_add` with the recursive call at `1n+p`.
---
Commutativity: `Refl.add(x, y) == Refl.add(y, x)`. Everybody knows it, and it's the first proof here that takes real planning.

You have the two lemmas it needs: `Tutorial.zero_add` and `Addition.succ_add`, one for each case of the induction. Lemmas from an earlier level have a prefix that says which world they came from. The difficulty is that they rarely fit the goal as they stand. A lemma points in one direction and your goal may want the other, so `Equal.sym` flips it and `Equal.trans` chains two.

Those take their endpoints as arguments. That's a lot of typing, but there's no guessing: everything they ask for, you can read off the **Goal**. `Equal.trans(Nat, a, b, c, ab, bc)` goes from `a` to `c` through `b`, with the two proofs last.

Work like this. Write the `match`, with a hole in each case, and read each **Goal**. One side will have computed, and the other will be stuck in a shape one of your lemmas talks about.

<!-- @conclusion -->
This proof is correct, and it's hard to read. That's Bend's way: nothing is implicit, so everything is on the page. The next two levels are about writing long chains so that they stay readable.
