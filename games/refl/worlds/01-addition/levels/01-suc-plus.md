---
id: suc-plus
index: 1
title: "suc-+"
learning_goals:
  - "Induction on the argument the definition recurses on."
  - "`suc x + y ≡ suc (x + y)`: the mirror image of the defining clause `x + suc y = suc (x + y)`."
unlocks:
  lemmas:
    - name: "suc-+"
      agda: "suc-+"
      lean: "succ_add"
      doc: "suc-plus.md"
hints:
  - text: "Which argument does `_+_` look at? **Case split** on that one, `y`."
  - text: "The `zero` clause's goal is `suc x ≡ suc x`. The other is `suc (suc x + y) ≡ suc (suc (x + y))`, which has `suc` around this very statement for the smaller `y`. You have a lemma for putting `suc` around an equation."
  - text: "`suc-+ x zero = refl`, and `suc-+ x (suc y) = cong suc (suc-+ x y)`."
---
The definition of `_+_` says what `x + suc y` is: the `suc` moves outside. It says
nothing about `suc x + y`, because addition only ever looks at its **second**
argument. So `suc x + y` is stuck until you know what `y` is. To say what it
equals for *every* `y`, you need induction.

You have done this once already, in the Tutorial's `zero-+`, and the recipe is the
same:

1. **Case split** on the variable that lets addition compute.
2. In the `zero` clause, ask for the **Goal**. Addition has nothing left to do, so
   look at whether the two sides now match.
3. In the `suc` clause, ask for the **Goal** again. Both sides have computed a
   little. Look for the statement you are proving, for a smaller number, sitting
   inside.

Reading the goals is the skill this world practises. They get longer from here,
and they will tell you what to do far more often than you might expect.

<!-- @conclusion -->
The definition of `_+_` tells you how to deal with a `suc` on the right.
`zero-+` and `suc-+` now handle `zero` and `suc` on the left. With a lemma for
each case, you can prove commutativity.
