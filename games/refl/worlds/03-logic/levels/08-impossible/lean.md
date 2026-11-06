---
learning_goals:
  - "`x ≠ y` unfolds to `x = y → False`."
  - "Different constructors can never be equal, and Lean knows it."
  - "`cases` on an impossible equation leaves nothing to do."
hints:
  - text: "The goal is `zero ≠ n.succ`. `intro h` gives you `h : zero = n.succ`, and the goal `False`. Can there be such an `h`?"
  - text: "There can't, and `cases h` says so: it tries to match `h` against `rfl`, finds that it can't, and has no cases left."
  - text: "`intro h` on one line and `cases h` on the next. `exact nofun` also works."
example_explanation: |-
  1. `¬ (succ zero = succ (succ zero))` unfolds to a function from that equation to `False`.
  2. Lean strips the shared `succ` and compares `zero` with `succ zero`, which are different constructors.
  3. So `cases h` has nothing to do. The exercise works the same way with a variable inside the `succ`.
---
You now have enough logic to say two numbers are *different*. `x ≠ y` means `¬ (x = y)`, and you know what `¬` unfolds to, so this is a
function that takes a proof of `x = y` and returns `False`. Type `≠` as `\ne`.

Why should `zero ≠ succ n` hold? Think about how a proof of an equation is made. There's one constructor, `rfl`, and it only fits when
the two sides compute to the same term. But `zero` and `succ n` are built with different constructors, so no amount of computing can ever
bring them together. There can't be a `rfl` for them, and so there's no proof of that equation at all.

Lean knows this. You saw what `cases` does on `False`: no constructors, no cases, done. Used on an equation, `cases` tries to match it
against `rfl`. If the two sides can't be unified, there are no cases left. So take the argument with `intro`, and then take it apart.

<!-- @conclusion -->
Every proof that two constructors differ looks like this. `nofun` is a one-word version, which you can also use as a term: it's a function
that can't be applied, because its argument can't exist. The next level puts this to use.
