---
learning_goals:
  - "`A ∧ B` is a structure with fields `left` and `right`; `⟨a, b⟩` builds one."
  - "`cases` on a pair names its parts."
hints:
  - text: "`cases p with`, then one line, `| intro a b => sorry`. Press **Goal** on the `sorry`: `a : A` and `b : B` are above the line."
  - text: "The goal is `B ∧ A`. `⟨x, y⟩` builds a pair, where the first part proves the left side."
  - text: "`| intro a b => exact ⟨b, a⟩`."
example_explanation: |-
  1. `cases` the outer pair, then `cases` the inner one, to name all three parts.
  2. Read the target's nesting.
  3. Reassemble with `⟨…, …⟩`. Use the same decomposition and reassembly in the exercise's different arrangement.
---
To prove "A and B" you need a proof of `A` and a proof of `B`, so a proof of `A ∧ B` is a **pair** of proofs:

```lean
structure And (a b : Prop) : Prop where
  intro ::
  left : a
  right : b
```

You build a pair with `⟨a, b⟩`. Type the brackets as `\<` and `\>`. To use one, either project out a part with `p.left` and
`p.right`, or take it apart with `cases`:

```lean
  cases p with
  | intro a b => sorry
```

`intro` is the name of `And`'s only constructor, so there's one case, and `a` and `b` are names you choose for the two
parts. This `intro` is unrelated to the tactic you met last level; it just has the same name.

The statement says "and" is commutative. Take `p` apart, then build the pair you need.

<!-- @conclusion -->
`And` is a *structure*, and `cases` on a structure gives you its one constructor. `exact ⟨p.right, p.left⟩` is also a complete
proof, with no `cases` at all.
