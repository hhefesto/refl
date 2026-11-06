---
learning_goals:
  - "`A ∨ B` has two constructors; a proof records which side."
  - "`cases` on a sum handles both."
hints:
  - text: "`cases s with`, and two cases, `| inl a => sorry` and `| inr b => sorry`. The goal is `B ∨ A` in both."
  - text: "In the first you hold an `A`, and the goal's `A` is on its *right*, so use `Or.inr`. The second is the mirror image."
  - text: "`| inl a => exact Or.inr a`, and `| inr b => exact Or.inl b`."
example_explanation: |-
  1. A disjunction holds one of two payloads, and you don't know which.
  2. Handle both, recovering an `A` in each case.
  3. Return the payload. The exercise instead puts it into the target's appropriate constructor.
---
To prove "A or B" you pick a side and prove that side. So `Or` is a type with two constructors, each carrying a proof:

```lean
inductive Or (a b : Prop) : Prop where
  | inl (h : a) : Or a b
  | inr (h : b) : Or a b
```

`Or.inl` proves the left side, and `Or.inr` the right. The symbol `∨` (type `\or`) is notation for `Or`.

That's also how you use one. If you're given `s : A ∨ B`, you don't know which side you have, so you must be ready for
both. `cases s with` takes one line for each constructor, and you name what's inside:

```lean
  cases s with
  | inl a => sorry
  | inr b => sorry
```

Press **Goal** on each `sorry` to see what you're holding. Then decide which constructor you need on the way out. The goal is
`B ∨ A`, with the sides swapped.

<!-- @conclusion -->
Notice the asymmetry with `∧`. A pair is *built* by one constructor and *used* by two projections. A sum is *built* by two
constructors and *used* by one case analysis. They're mirror images, which is why logicians call them duals.
