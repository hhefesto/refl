---
id: refl
index: 2
title: "refl"
unlocks:
  syntax:
    - name: "reflexivity"
      agda: "refl"
      lean: "rfl"
      bend2: "{==}"
      doc: "refl.md"
learning_goals:
  - "`refl` proves any equality whose two sides compute to the same term."
  - "The checker performs the walk you just did by hand."
  - "Reflexivity is not a universal proof: it needs the sides to meet."
hints:
  - text: "The statement is the one you just proved the long way. Press **Check** to turn the `?` into a numbered goal, then **Goal** (`C-c C-,`) to see what it asks for: `2 + 2 ≡ 4`."
    hidden: true
  - text: "Equality has one constructor, `refl : x ≡ x`: a proof that something equals itself. More elaborate proofs can use hypotheses, induction and lemmas; here we can use the constructor directly."
    hidden: true
  - text: "For bare `refl` to fit `2 + 2 ≡ 4`, the endpoints must compute to the same term. That is what you established by hand last level. The checker performs that computation when checking the proof's type."
    hidden: true
  - text: |-
      The whole proof is one word:

      ```agda
      two-plus-two = refl
      ```

      Type it into the editor and **Check**, or select the hole and **Give** `refl`.
    hidden: true
---
The statement is the one you just finished: `two-plus-two : 2 + 2 ≡ 4`, the
same proposition, the same two endpoints. Last level you walked them together
by hand. This time, say nothing about the walk at all.

Equality has exactly **one constructor**:

```agda
data _≡_ {A : Set} (x : A) : A → Set where
  refl : x ≡ x
```

Read it carefully. `refl` proves `x ≡ x` — a thing equal to *itself*, with the
same `x` on both sides. This describes when the constructor fits directly.
Equality proofs can also use hypotheses, induction and existing lemmas;
their endpoints need not be definitionally equal. In this example they are,
so we can use bare `refl`.

That looks far too weak for `2 + 2 ≡ 4`, where the two sides are plainly not
written the same. But "written the same" is not the test. When Agda checks
whether `refl` fits, it **computes both sides** and compares the results — the
very walk you did by hand, performed silently. `2 + 2` reduces to
`suc (suc (suc (suc zero)))`, `4` denotes that same term, and so `refl` fits.

This is why the `≡⟨⟩` steps last level needed no justification: each was a
claim that the checker could get from one line to the next on its own. Writing
the middle out taught you what happens; it was never something Agda needed.

**Check** (`C-c C-l`) finds holes and errors. Select a hole and press
**Goal** (`C-c C-,`) to inspect its required type, then **Give**
(`C-c C-SPC`) an expression, or edit the definition and Check again.

<!-- @conclusion -->
Two proofs, one statement. The long one showed the computation; the short one
asked the checker to do it. Both rest on the same fact: the endpoints are
**definitionally equal**, the same term once you compute.

That word *definitionally* is the limit. `refl` proves `2 + 2 ≡ 4` because
computation finishes the job, but it will not prove `zero + x ≡ x`: addition
here recurses on its **second** argument, so `zero + x` is stuck on the
variable `x` and cannot reduce further. Equations like that need additional reasoning,
and the rest of this world is how to build one.
