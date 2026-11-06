---
learning_goals:
  - "`A ↔ B` is a structure of two functions, `mp` and `mpr`."
  - "Reusing earlier lemmas as fields."
hints:
  - text: "A proof of `↔` is a pair: `⟨forward, backward⟩`. **Goal** after `constructor` shows the two functions you need: `A ∧ B → B ∧ A`, and the other way."
  - text: "You proved exactly that earlier in this world, for any `A` and `B`, and it's called `and_swap`. It fits both."
  - text: "`exact ⟨and_swap, and_swap⟩`."
example_explanation: |-
  1. Read `↔` as two function types.
  2. The forward function adds a trivial proof with `⟨a, True.intro⟩`.
  3. The reverse function projects it away. In the exercise, supply the two appropriately typed functions.
---
"A if and only if B" means two things: `A` implies `B`, and `B` implies `A`. So a proof of it is two functions, one for each direction, packaged in a
structure:

```lean
structure Iff (a b : Prop) : Prop where
  intro ::
  mp : a → b
  mpr : b → a
```

You've built a structure before: `⟨a, b⟩` built an `And`, and that same notation works for any structure. Type `↔` as `\<->`.

The statement is `A ∧ B ↔ B ∧ A`: "A and B" holds exactly when "B and A" does.

You could write out both functions from scratch. But look through your inventory first, since you may have proved one already. Proofs are values, so
you can pass a lemma you've proved as an argument, just like any other function.

<!-- @conclusion -->
In Lean's library, this exact fact is `And.comm`, and now you've earned it. `h.mp` and `h.mpr` get the two directions back out of a proof of `↔`.
