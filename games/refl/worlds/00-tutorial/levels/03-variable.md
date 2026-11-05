---
id: variable
index: 3
title: "A variable in the way"
learning_goals:
  - "`∀ (x : ℕ) → …` is a function type: the proof takes `x` as an argument."
  - "The context panel lists what is in scope inside a hole."
  - "`refl` still works when both sides are literally the same expression."
hints:
  - text: "Press **Check**, select the hole and press **Goal**. What do the two sides of the goal look like?"
  - text: "The goal is `x ≡ x`. Nothing has to compute: both sides are already the same term, which is what `refl` proves. Give `refl`."
---
So far every statement was about particular numbers. This one is about all of
them: `∀ (x : ℕ) → x ≡ x` reads "for every natural number `x`, `x` equals `x`".

In Agda a *for all* is a function type. A proof of this statement is a function
that takes a number `x` and returns a proof of `x ≡ x`. That is why the template
already has `x` on the left of `=`: in `same x = ?`, `x` is the function's
argument, and the hole is what the function returns.

Press **Check**, select the hole and press **Goal**. The panel now has two parts.
Above the line is the **context**, the things you may use: here `x : ℕ`. Below
the line is the **goal**, the type your term must have.

You don't know which number `x` is, so nothing can compute. But the test from
the last level was never "are these numbers"; it was "are the two sides the same
term?"

<!-- @conclusion -->
Arguments on the left of `=` are how you "introduce" a for-all. You will also
meet the anonymous form `λ x → …` on the right-hand side; they mean the same
thing.

Keep an eye on the context panel. From here on, it is where proofs come from.
