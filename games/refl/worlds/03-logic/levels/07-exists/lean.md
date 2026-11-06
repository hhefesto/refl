---
learning_goals:
  - "`∃ n, P n` is a witness paired with a proof about it."
  - "The witness is data: you choose it."
hints:
  - text: "A proof is a pair, written `⟨n, p⟩`. Which `n` makes `n + 1 = 3`?"
  - text: "With `2` as the witness, the second part must prove `2 + 1 = 3`, and that computes."
  - text: "`exact ⟨2, rfl⟩`."
example_explanation: |-
  1. Choose a witness, here `4`.
  2. Substitute it into the predicate, obtaining `4 + 2 = 6`.
  3. Prove the computed equality with `rfl`. Choose a different witness for the exercise's equation.
---
How do you prove that something exists? In ordinary maths you might argue that it can't fail to. Here you show it. A proof of "there
is an `n` such that `P n`" is a **pair**: a particular number, called the **witness**, and a proof that it works.

```lean
inductive Exists {α : Sort u} (p : α → Prop) : Prop where
  | intro (w : α) (h : p w) : Exists p
```

Look at the type of `h`, `p w`. The type of the second part mentions the *value* of the first. `∃ n : MyNat, n + 1 = 3` is the
type of pairs `⟨n, h⟩` where `h` proves `n + 1 = 3` for that very `n`. Type `∃` as `\ex`.

The anonymous constructor `⟨…, …⟩` you used for `∧` works here too. You pick the witness first, since it's data and the choice is
yours. Then what the second part has to prove depends on what you picked.

<!-- @conclusion -->
A proof of `∃` really does contain the number, though Lean is careful about getting it back out: because `∃` lives in `Prop`, a program
can't look inside it. For a witness a program can use, Lean has `Subtype` and `Sigma`.
