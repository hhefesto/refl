---
learning_goals:
  - "A language is a predicate; union is `∨` pointwise, intersection is `∧` pointwise."
  - "Proofs of membership are data, and lemmas about languages are functions on that data."
hints:
  - text: "**Goal** shows `union P Q n`, with `pq : inter P Q n` above the line. `cases` will unfold `inter` for you, because it looks for a constructor. `cases pq with` and `| intro p q => sorry`."
  - text: "You now hold a proof for each of `P n` and `Q n`, and the goal only wants one side. Either choice works, and `exact` will unfold `union`."
  - text: "`cases pq with` and `| intro p _ => exact Or.inl p`, where `_` means you don't need that part."
example_explanation: |-
  1. Evaluate the membership function at `n`.
  2. Extract its second component with `.right`.
  3. Inject it into the left side of the target. Unfold the exercise's predicate operations before making its choice.
---
In *Symbolic and Automatic Differentiation of Languages* (ICFP 2021), Conal Elliott treats a formal language as a predicate on strings: `P s` is the
statement "`s` is in the language". Here's that idea, with strings replaced by numbers to keep things simple:

```lean
def Pred := MyNat → Prop
def union (P Q : Pred) : Pred := fun n => P n ∨ Q n
def inter (P Q : Pred) : Pred := fun n => P n ∧ Q n
```

Read the definitions the way a logician would. A number is in the union if it's in `P` or in `Q`. It's in the intersection if it's in `P` and in `Q`. All
the set theory you know turns into the logic you've just learned.

Prove that intersection is contained in union: anything in both is in at least one. The statement gives you `P`, `Q`, `n` and a proof of membership in
`inter P Q`, and asks for a proof of membership in `union P Q`. **Goal** won't unfold these for you, so unfold them in your head. After that, this is two
moves you already know.

<!-- @conclusion -->
This is the Curry–Howard view of formal languages: a proof of `P n` is a witness that `n` is in the language, and this lemma is a function that turns a
witness for both into a witness for either.

**Logic World complete.** Equality World needs this world and Addition World.
