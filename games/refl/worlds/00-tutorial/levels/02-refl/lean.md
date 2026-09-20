---
learning_goals:
  - "`rfl` proves any equality whose two sides compute to the same value."
  - "The kernel performs the walk you just did by hand."
  - "Reflexivity is not a universal proof: it needs the sides to meet."
hints:
  - text: "The statement is the one you just proved the long way. Replace `sorry` and press **Check**; the goal in the right panel is `2 + 2 = 4`."
    hidden: true
  - text: "Equality in Lean is an inductive type with a single constructor, `Eq.refl : a = a` — a proof that something equals *itself*. The tactic `rfl` is how you hand it to a goal."
    hidden: true
  - text: "For bare `rfl` to close this goal, the endpoints must compute to the same term. Last level both reached `succ (succ 2)`. The kernel performs that computation when checking the proof. Other equalities may require hypotheses, induction or lemmas."
    hidden: true
  - text: |-
      The whole proof is one indented word:

      ```lean
        rfl
      ```

      Replace the block with that and press **Check**.
    hidden: true
example_explanation: |-
  A different sum, `(3 : MyNat) + 1`, and the same one-word proof. It computes
  to `succ 3`, which is what `4` denotes, so the two sides are the same value
  and `rfl` closes the goal. Nothing about the proof changed when the numbers
  did — only the arithmetic the kernel performs.
---
The statement is the one you just finished: `(2 : MyNat) + 2 = 4`, the same
proposition, the same two endpoints. Last level you brought them together with
two `conv` blocks. This time, say nothing about the walk at all.

Equality is an inductive type with exactly **one constructor**:

```lean
inductive Eq : α → α → Prop where
  | refl (a : α) : Eq a a
```

Read it carefully. It proves `a = a` — a thing equal to *itself*, the same `a`
on both sides. The tactic `rfl` offers reflexivity to this equality goal.
Other equality proofs can use hypotheses, induction or lemmas, even when
their endpoints do not compute to the same term.

That looks far too weak for `2 + 2 = 4`, where the sides are plainly not
written the same. But "written the same" is not the test. When Lean checks
`rfl`, it **computes both sides** and compares the results — the very walk you
did by hand, performed silently. `2 + 2` reduces to `succ (succ (succ (succ
zero)))`, `4` denotes that same value, and `rfl` closes the goal.

This is why `change` accepted each of your rewrites last level, and why `conv`
finished the proof the moment both sides agreed: every step was a claim the
kernel could verify by computing. Writing the middle out taught you what
happens; it was never something Lean needed.

Edit the block and **Check** (`C-c C-l`). To inspect the goal, put the cursor
inside the block and press **Goal** (`C-c C-,`).

<!-- @conclusion -->
Two proofs, one statement. The long one showed the computation; the short one
asked the kernel to do it. Both rest on the same fact: the endpoints are
**definitionally equal**, the same value once you compute.

That word *definitionally* is the limit. `rfl` proves `2 + 2 = 4` because
computation finishes the job, but it will not prove `zero + x = x`: addition
here recurses on its **second** argument, so `zero + x` is stuck on the
variable `x` and cannot reduce further. Equations like that need additional reasoning,
and the rest of this world is how to build one.
