---
learning_goals:
  - "Use `change` to see a goal after computing."
  - "Prove an equality from its constructor alone when both sides compute to the same value."
  - "Know the limit: the sides have to meet by computing."
hints:
  - text: "Put `change 4 = 4` on the line above `sorry`, then put the cursor on `sorry` and press **Goal**. Lean accepted the change, so the two goals are the same by computing. What does the new goal say about its two sides?"
  - text: |-
      The goal `4 = 4` has the same value on both sides, which is exactly what `Eq.refl` proves, and the tactic `rfl` hands it to the goal. The `change` was only there to show you; the proof needs just one indented word:

      ```lean
        rfl
      ```

      Replace the block with that and press **Check**.
example_explanation: |-
  The same one-word proof for a longer walk. Computing `(20 : MyNat) + 22`
  applies `m + succ n = succ (m + n)` twenty-two times, so last level's `change`
  steps would have to spell out a long walk. `rfl` does not grow with the
  computation: the kernel does the extra work, and the proof stays one word.
---
The statement is the one you just finished: `(2 : MyNat) + 2 = 4`. Last level
you brought its two sides together with two `conv` blocks. This time, let the
kernel take the walk, and read what it found.

Put the cursor on `sorry` and press **Goal** (`C-c C-,`). Lean shows the goal as
you wrote it, `2 + 2 = 4`; it does not compute a goal just to display it. So ask
it to, with the `change` you learned last level. Put this above `sorry` and look
at the goal again:

```lean
  change 4 = 4
```

Lean accepts that, because `2 + 2` and `4` compute to the same value.

Equality is an inductive type with exactly **one constructor**:

```lean
inductive Eq : α → α → Prop where
  | refl (a : α) : Eq a a
```

It proves only that a thing equals *itself*, with the same `a` on both sides,
and the tactic `rfl` hands it to a goal. That looks far too weak for `2 + 2 = 4`,
where the sides are plainly not written the same. But "written the same" is not
the test: Lean compares the two sides after computing them.

So which tactic closes the goal you just read? Edit the block and **Check**
(`C-c C-l`).

<!-- @conclusion -->
Two proofs, one statement. The long one showed the computation; the short one
asked the kernel to do it. You did not even need the `change`: `rfl` alone
computes both sides. Both proofs rest on the same fact: the endpoints are
**definitionally equal**, the same value once you compute. It is also why
`change` accepted each of your rewrites last level: every step was a claim the
kernel could settle on its own.

That word *definitionally* is the limit. `rfl` proves `2 + 2 = 4` because
computation finishes the job, but it will not prove `zero + x = x`: addition
here recurses on its **second** argument, so `zero + x` is stuck on the
variable `x` and cannot reduce further. Equations like that need additional reasoning,
and the rest of this world is how to build one.
