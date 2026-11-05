---
learning_goals:
  - "Compare a law as written with the goal Bend computes from it."
  - "Prove an equality with reflexivity alone when both sides compute to the same term."
  - "Know the limit: the sides have to meet by computing."
hints:
  - text: "Press **Check** on the untouched `?goal` and read the type Bend reports for it. Compare it with the law as you wrote it. What did Bend do between the two, and what does the report say about the two sides?"
  - text: |-
      Bend reports `{4n == 4n : Nat}`: the same term on both sides, which is exactly what the reflexivity proof `{==}` proves.

      ```bend
      def two_plus_two():
        {==}
      ```

      Select the hole and **Give** `{==}`, or edit the definition and **Check**.
example_explanation: |-
  The same one-token proof for a longer walk. Computing `Refl.add(20n, 22n)`
  takes twenty-two steps, so last level's paths would need dozens of waypoints.
  `{==}` does not grow with the computation: the checker does the extra work,
  and the proof stays one token.
---
The law is the one you just finished: `{Refl.add(2n, 2n) == 4n : Nat}`. Last
level you built paths from both sides to a common middle. This time, let the
checker take the walk, and read what it found.

Press **Check** (`C-c C-l`) on the untouched `?goal` and read the type Bend
reports for it. That is the law with both sides computed as far as they will
go. Compare it with the law as you wrote it.

`{==}` is the **reflexivity proof**. It proves only that a thing equals *itself*,
with the same term on both sides; last level `Refl.arrive` supplied it at the
middle. That looks far too weak for `{Refl.add(2n, 2n) == 4n : Nat}`, where the
sides are plainly not written the same. But "written the same" is not the test:
Bend compares the two sides after computing them.

So which proof fits the goal you just read? Select the hole and **Give**
(`C-c C-SPC`) it, or edit the definition and **Check** again.

<!-- @conclusion -->
Two proofs, one law. The long one displayed two paths; the short one
asked the checker to find it. Both rest on the same fact: the endpoints are
**definitionally equal**, the same term once you compute.

That word *definitionally* is the limit. `{==}` proves this law because
computation finishes the job, but it will not prove
`{Refl.add(0n, x) == x : Nat}`: addition here inspects its **second**
argument, so with a variable there nothing computes. Equations like that need
additional reasoning, and the rest of this world is how to build it.
