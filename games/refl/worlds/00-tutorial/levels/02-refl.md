---
id: refl
index: 2
title: "Let the checker walk"
unlocks:
  syntax:
    - name: "reflexivity"
      agda: "refl"
      lean: "rfl"
      bend2: "{==}"
      doc: "refl.md"
learning_goals:
  - "Compare a goal as written with the same goal after computing."
  - "Prove an equality from its constructor alone when both sides compute to the same term."
  - "Know the limit: the sides have to meet by computing."
hints:
  - text: "Press **Check** and read the type beside the hole. Select the hole, press **Goal** and read it again. What did the checker do between the two, and what does the second one say about the two sides?"
    hidden: true
  - text: |-
      **Goal** shows `4 ≡ 4`: the same term on both sides, which is exactly what `refl : x ≡ x` proves.

      ```agda
      two-plus-two = refl
      ```

      Type it into the editor and **Check**, or select the hole and **Give** `refl`.
    hidden: true
---
The statement is the one you just finished: `two-plus-two : 2 + 2 ≡ 4`. Last
level you wrote out the walk between its two sides. This time, let the checker
take the walk, and read what it found.

Press **Check** (`C-c C-l`). The hole appears with the type as you wrote it,
`2 + 2 ≡ 4`. Now select the hole and press **Goal** (`C-c C-,`), which shows the
same type computed as far as it will go. Compare the two.

Equality has exactly **one constructor**:

```agda
data _≡_ {A : Set} (x : A) : A → Set where
  refl : x ≡ x
```

It proves only that a thing equals *itself*, with the same `x` on both sides.
That looks far too weak for `2 + 2 ≡ 4`, where the sides are plainly not written
the same. But "written the same" is not the test: the checker compares the two
sides after computing them.

So which term fits the goal you just read? **Give** (`C-c C-SPC`) it to the
selected hole, or edit the definition and **Check** again.

<!-- @conclusion -->
Two proofs, one statement. The long one showed the computation; the short one
asked the checker to do it. Both rest on the same fact: the endpoints are
**definitionally equal**, the same term once you compute. It is also why the
`≡⟨⟩` steps last level needed no justification: each was a claim the checker
could settle on its own.

That word *definitionally* is the limit. `refl` proves `2 + 2 ≡ 4` because
computation finishes the job, but it will not prove `zero + x ≡ x`: addition
here recurses on its **second** argument, so `zero + x` is stuck on the
variable `x` and cannot reduce further. Equations like that need additional reasoning,
and the rest of this world is how to build one.
