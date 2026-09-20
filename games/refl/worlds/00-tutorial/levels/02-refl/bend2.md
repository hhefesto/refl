---
learning_goals:
  - "`{==}` proves any equality whose two sides compute to the same term."
  - "The checker performs the walk you just did by hand."
  - "Reflexivity is not a universal proof: it needs the sides to meet."
hints:
  - text: "The law is the one you just proved the long way. Press **Check**; `?goal` is reported as the open goal, with its type normalised."
    hidden: true
  - text: "Look at what **Check** printed. Bend normalised the goal for you: both endpoints appear as the same numeral. That is the meeting point you wrote out by hand last level, found by the checker on its own."
    hidden: true
  - text: "`{==}` is the reflexivity proof. It fits any equality whose two sides are the same term — and after normalisation, these are."
    hidden: true
  - text: |-
      The whole proof is one token, and no annotation this time:

      ```bend
      def two_plus_two():
        {==}
      ```

      Select the hole and **Give** `{==}`, or edit the definition and **Check**.
    hidden: true
example_explanation: |-
  A different sum, `3n + 1n`, and the same one-token proof. It computes to
  `Succ{3n}`, which is what `4n` denotes, so the two sides are the same term
  and `{==}` proves the law. Nothing about the proof changed when the numbers
  did — only the arithmetic the checker performs.
---
The law is the one you just finished: `{Refl.add(2n, 2n) == 4n : Nat}`, the
same proposition, the same two endpoints. Last level you built paths from
both sides to a common middle. This time, supply just the proof token.

`{==}` is the **reflexivity proof**. It proves an equality whose two sides are
the same term. Other equality proofs can use hypotheses, induction or lemmas;
they do not all require definitionally equal endpoints. Here computation
makes the endpoints identical, so reflexivity fits directly.

That looks far too weak for `{Refl.add(2n, 2n) == 4n : Nat}`, where the sides
are plainly not written the same. But "written the same" is not the test.
Bend **normalises both sides** and compares the results — the very walk you
did by hand, performed silently. You can watch it happen: press **Check** on
the untouched `?goal` and read the type Bend reports. It has already brought
both endpoints to one numeral.

Last level `Refl.arrive` supplied reflexivity at the middle, `Refl.step`
checked each computational step, and `Refl.meet` composed the two paths.
Here Bend performs the endpoint computation without those intermediate terms.

**Check** (`C-c C-l`) reports holes with their normalised types. Select a
hole and press **Goal** (`C-c C-,`) to inspect it, then **Give**
(`C-c C-SPC`) an expression, or edit the definition and Check again.

<!-- @conclusion -->
Two proofs, one law. The long one displayed two paths; the short one
asked the checker to find it. Both rest on the same fact: the endpoints are
**definitionally equal**, the same term once you compute.

That word *definitionally* is the limit. `{==}` proves this law because
computation finishes the job, but it will not prove
`{Refl.add(0n, x) == x : Nat}`: addition here inspects its **second**
argument, so with a variable there nothing computes. Equations like that need
additional reasoning, and the rest of this world is how to build it.
