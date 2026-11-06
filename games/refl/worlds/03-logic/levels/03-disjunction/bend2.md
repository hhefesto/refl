---
learning_goals:
  - "`A | B` has two constructors; a proof records which side."
  - "`match` on a sum handles both."
hints:
  - text: "`match s:`, then `case Inl{a}:` and `case Inr{b}:`. The goal is `Either<&1, &1, B, A>` in both, Bend's name for `B | A`."
  - text: "In the first case you hold an `A`, and the goal's `A` is on its *right*, so use `Inr`. The second is the mirror image."
  - text: "`case Inl{a}:` is `Inr{a}`, and `case Inr{b}:` is `Inl{b}`."
example_explanation: |-
  1. A disjunction holds one of two payloads, and you don't know which.
  2. Handle both, recovering an `A` in each case.
  3. Return the payload. The exercise instead puts it into the target's appropriate constructor.
---
To prove "A or B" you pick a side and prove that side. So `A | B` is a data type with two constructors, each carrying a proof: `Inl{a}` for the left side and `Inr{b}` for the right. **Goal** prints `A | B` as `Either<&1, &1, A, B>`.

Unlike a classical *or*, a proof here says *which* side holds. It's data, and a program can look at it.

That's also how you use one. If you're given `s : A | B`, you don't know which side you have, so you must be ready for both:

```
match s:
  case Inl{a}:
    ?first
  case Inr{b}:
    ?second
```

Then decide which constructor you need on the way out. The goal is `B | A`, with the sides swapped.

<!-- @conclusion -->
Notice the asymmetry with `&`. A pair is *built* by one constructor and *used* by taking two parts out. A sum is *built* by two constructors and *used* by one case analysis. They're mirror images, which is why logicians call them duals.
